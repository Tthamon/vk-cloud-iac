#!/bin/bash
set -e

if [ -f .env ]; then
    source .env
fi

echo "=== Шаг 1: Получение state из S3 ==="
cd terraform

# Инициализируем с S3 backend
terraform init \
  -reconfigure \
  -backend-config="bucket=$BUCKET_NAME" \
  -backend-config="access_key=$S3_ACCESS_KEY" \
  -backend-config="secret_key=$S3_SECRET_KEY" \
  -input=false

# Скачиваем state локально
terraform state pull > local.tfstate
echo "State получен из S3"

echo ""
echo "=== Шаг 2: Переключение на local backend ==="

mv backend.tf backend.tf.bak

cat > backend.tf << 'EOF'
terraform {
  backend "local" {
    path = "./local.tfstate"
  }
}
EOF

terraform init -reconfigure -input=false
echo "Переключено на local backend"

echo ""
echo "=== Шаг 3: Очистка S3 бакета ==="

AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY \
AWS_SECRET_ACCESS_KEY=$S3_SECRET_KEY \
aws s3 rm s3://$BUCKET_NAME --recursive \
  --endpoint-url https://hb.ru-msk.vkcloud-storage.ru

echo "Бакет очищен"

echo ""
echo "=== Шаг 4: Удаление инфраструктуры ==="

terraform destroy -auto-approve
echo "Инфраструктура удалена"

echo ""
echo "=== Шаг 5: Удаление образа Packer ==="
cd ..
IMAGE_ID=$(openstack image list \
    --name "$IMAGE_NAME" \
    --format value -c ID \
    | head -1 || echo "")

if [ -n "$IMAGE_ID" ]; then
    openstack image delete "$IMAGE_ID"
    echo "Образ удалён"
else
    echo "Образ не найден"
fi

echo ""
echo "=== Шаг 6: Очистка локальных файлов ==="
cd terraform
rm -rf .terraform/
rm -f .terraform.lock.hcl plan.tfplan backend_override.tf
rm -f local.tfstate local.tfstate.backup
rm -f backend.tf
mv backend.tf.bak backend.tf

echo ""
echo "=== Готово! ==="
echo "Запустите ./deploy.sh для нового развертывания"