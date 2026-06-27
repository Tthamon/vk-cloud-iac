#!/bin/bash
set -e

# Проверка наличия инструментов
for cmd in terraform packer aws openstack; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ $cmd не установлен"
        exit 1
    fi
done
echo "Все инструменты установлены"

# Загрузка переменных
if [ -f .env ]; then
    source .env
    echo "Переменные загружены из .env"
else
    echo "Файл .env не найден"
    exit 1
fi

# Проверка обязательных переменных
required_vars=(
    "PROJECT_NAME"
    "MY_IP"
    "BUCKET_NAME"
    "S3_ACCESS_KEY"
    "S3_SECRET_KEY"
    "OS_USERNAME"
    "OS_PASSWORD"
    "OS_PROJECT_ID"
    "OS_AUTH_URL"
    "OS_USER_DOMAIN_NAME"
    "OS_REGION_NAME"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Переменная $var не задана"
        exit 1
    fi
done

echo "Все переменные заданы"


cd terraform

echo ""
echo "=== Проверка S3 бакета ==="

BUCKET_EXISTS=$(AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY \
    AWS_SECRET_ACCESS_KEY=$S3_SECRET_KEY \
    aws s3api head-bucket \
    --bucket "$BUCKET_NAME" \
    --endpoint-url "https://hb.ru-msk.vkcloud-storage.ru" \
    2>&1 && echo "yes" || echo "no")

if [ "$BUCKET_EXISTS" = "yes" ]; then
    echo "Бакет $BUCKET_NAME существует"

    # Сразу подключаемся к существующему бакету
    terraform init -reconfigure \
        -backend-config="bucket=$BUCKET_NAME" \
        -backend-config="access_key=$S3_ACCESS_KEY" \
        -backend-config="secret_key=$S3_SECRET_KEY" \
        -input=false

else
    echo "Создание бакета"

    # Временный local backend
    cat > backend_override.tf << 'EOF'
terraform {
  backend "local" {
    path = "/tmp/terraform_init.tfstate"
  }
}
EOF

    terraform init -reconfigure -input=false

    terraform apply -auto-approve \
        -target=aws_s3_bucket.terraform_state \
        -target=aws_s3_bucket_versioning.terraform_state

    rm backend_override.tf

    echo "Бакет $BUCKET_NAME создан"

    # Переключаемся на S3 backend
    terraform init \
        -migrate-state \
        -force-copy \
        -backend-config="bucket=$BUCKET_NAME" \
        -backend-config="access_key=$S3_ACCESS_KEY" \
        -backend-config="secret_key=$S3_SECRET_KEY" \

    echo "State перенесён в S3 бакет"
fi


echo ""
echo "=== Проверка образа Packer ==="

cd ../packer

if [ -f "image_name.txt" ] && [ -s "image_name.txt" ]; then
    echo "Образ уже существует: $(cat image_name.txt)"
else
    echo "Сборка образа"

    packer init .

    if ! packer validate .; then
        echo "Ошибка валидации Packer"
        exit 1
    fi
    echo "Packer конфиг валиден"

    # Создание временной инфраструктуры для Packer
    echo "Создание временной сети для Packer..."

    PACKER_NETWORK_ID=$(openstack network create packer-network \
        --format value -c id)
    echo "Сеть создана: $PACKER_NETWORK_ID"

    PACKER_SUBNET_ID=$(openstack subnet create packer-subnet \
        --network "$PACKER_NETWORK_ID" \
        --subnet-range 10.0.0.0/24 \
        --format value -c id)
    echo "Подсеть создана: $PACKER_SUBNET_ID"

    PACKER_ROUTER_ID=$(openstack router create packer-router \
        --format value -c id)
    echo "Роутер создан: $PACKER_ROUTER_ID"

    # Подключение роутера к внешней сети и подсети
    openstack router set packer-router \
        --external-gateway ec8c610e-6387-447e-83d2-d2c541e88164
    openstack router add subnet packer-router packer-subnet
    echo "Роутер настроен"

    # Создание SG packer-ssh
    echo "Создание security group packer-ssh..."

    # Проверка что SG не существует (актуально при повторном запуске)
    if openstack security group show packer-ssh &> /dev/null; then
        echo "Security group packer-ssh уже существует, используем её"
    else
        openstack security group create packer-ssh \
            --description "SG for Packer SSH access"
        openstack security group rule create packer-ssh \
            --protocol tcp \
            --dst-port 22 \
            --remote-ip 0.0.0.0/0 \
            --ingress
        echo "Security group packer-ssh создана"
    fi

    export PKR_VAR_network_id="$PACKER_NETWORK_ID"

    # Сборка образа
    if packer build .; then
        echo "Образ собран: $(cat image_name.txt)"
        BUILD_SUCCESS=true
    else
        echo "Ошибка сборки образа"
        BUILD_SUCCESS=false
    fi

    # Удаление временной инфраструктуры в любом случае
    echo "Удаление временной инфраструктуры Packer..."

    openstack security group delete packer-ssh
    echo "Security group packer-ssh удалена"

    openstack router remove subnet packer-router packer-subnet
    openstack router unset packer-router --external-gateway
    openstack router delete packer-router
    echo "Роутер удалён"

    openstack subnet delete packer-subnet
    echo "Подсеть удалена"

    openstack network delete packer-network
    echo "Сеть удалена"

    # Проверка результата сборки
    if [ "$BUILD_SUCCESS" = false ]; then
        exit 1
    fi

    if [ -f "image_name.txt" ] && [ -s "image_name.txt" ]; then
        echo "Образ создан: $(cat image_name.txt)"
    else
        echo "image_name.txt не найден"
        exit 1
    fi
fi


echo ""
echo "=== Валидация Terraform ==="

cd ../terraform

if terraform fmt -check -recursive; then
    echo "Форматирование корректно"
else
    echo "Проблемы с форматированием"
    terraform fmt -recursive
fi

if terraform validate; then
    echo "Конфигурация валидна"
else
    echo "Ошибка валидации Terraform"
    exit 1
fi


echo ""
echo "=== Развертывание инфраструктуры ==="

terraform plan -out=plan.tfplan
terraform apply -auto-approve plan.tfplan

echo ""
echo "=== Готово! ==="