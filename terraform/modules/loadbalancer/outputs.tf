output "load_balancer_ip" {
  value = vkcs_networking_floatingip.lb_fip.address
}

output "load_balancer_id" {
  value = vkcs_lb_loadbalancer.main.id
}