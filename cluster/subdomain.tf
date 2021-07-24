# create all Subdomains required by Kubernetes Deployments
resource "aws_route53_record" "deployments_subdomains" {
  for_each = toset(var.deployments_subdomains)

  zone_id = aws_route53_zone.base_domain.id
  name    = "${each.key}.${aws_route53_record.eks_domain.fqdn}"
  type    = "CNAME"
  ttl     = "5"
  records = ["${data.kubernetes_service.ingress_gateway.status.0.load_balancer.0.ingress.0.hostname}"]
}