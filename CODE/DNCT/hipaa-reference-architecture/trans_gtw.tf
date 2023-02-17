##### AWS Transit gateway #####

resource "aws_ec2_transit_gateway" "test_hipaa_transit_gateway" {
  description = "test-HIPAA Transit Gateway"
  auto_accept_shared_attachments = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support = "enable"
  vpn_ecmp_support = "enable"
  tags = {
    "Name" = "Test-HIPAA Transit Gateway"
  }

}

resource "aws_ec2_transit_gateway_vpc_attachment" "ManagementVPCtoTransitGateway" {
  subnet_ids         = [aws_subnet.mgmt_pvt_sub1.id, aws_subnet.mgmt_pvt_sub2.id]
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  vpc_id             = aws_vpc.management.id
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"
  tags = {
    "Name" = "Management Transit Gateway Attachment"
    "Purpose" = "Networking"
  }
  depends_on = [
    aws_subnet.mgmt_pvt_sub1, aws_subnet.mgmt_pvt_sub2,
  ]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "ProductionVPCtoTransitGateway" {
  subnet_ids         = [aws_subnet.prod_pvt_sub1.id, aws_subnet.prod_pvt_sub2.id]
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  vpc_id             = aws_vpc.production.id
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"
  tags = {
    "Name" = "Production Transit Gateway Attachment"
    "Purpose" = "Networking"
  }
  depends_on = [
    aws_subnet.prod_pvt_sub1, aws_subnet.prod_pvt_sub2,
  ]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "DevVPCtoTransitGateway" {
  subnet_ids         = [aws_subnet.dev_pvt_sub1.id, aws_subnet.dev_pvt_sub2.id ]
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  vpc_id             = aws_vpc.development.id
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"
  tags = {
    "Name" = "Development Transit Gateway Attachment"
    "Purpose" = "Networking"
  }
  depends_on = [
    aws_subnet.dev_pvt_sub1, aws_subnet.dev_pvt_sub2,
  ]
}

resource "aws_ec2_transit_gateway_route_table" "TransitGatewayExternalRouteTable" {
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  tags = {
    "Name" = "External Transit Gateway Route Table"
    "Purpose" = "Networking"
  }
}

resource "aws_ec2_transit_gateway_route_table" "TransitGatewayInternalRouteTable" {
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  tags = {
    "Name" = "Internal Transit Gateway Route Table"
    "Purpose" = "Networking"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "TransitGatewayExternalRouteTableAssociation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.ManagementVPCtoTransitGateway.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TransitGatewayExternalRouteTable.id
}

resource "aws_ec2_transit_gateway_route_table_association" "TransitGatewayProductionVPCRouteTableAssociation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.ProductionVPCtoTransitGateway.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TransitGatewayInternalRouteTable.id
}

resource "aws_ec2_transit_gateway_route_table_association" "TransitGatewayDevelopmentVPCRouteTableAssociation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.DevVPCtoTransitGateway.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TransitGatewayInternalRouteTable.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "TransitGatewayInternalRouteProp1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.ProductionVPCtoTransitGateway.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TransitGatewayInternalRouteTable.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "TransitGatewayInternalRouteProp2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.DevVPCtoTransitGateway.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TransitGatewayInternalRouteTable.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "TransitGatewayExternalRouteProp1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.ManagementVPCtoTransitGateway.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TransitGatewayExternalRouteTable.id
}

resource "aws_ec2_transit_gateway_route" "TransitGatewayInternalRoute1" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.ManagementVPCtoTransitGateway.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TransitGatewayInternalRouteTable.id
}

resource "aws_ec2_transit_gateway_route" "TransitGatewayExternalRoute1" {
  destination_cidr_block         = "${var.prod_vpc_cidr}"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.ProductionVPCtoTransitGateway.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TransitGatewayExternalRouteTable.id
}

resource "aws_ec2_transit_gateway_route" "TransitGatewayExternalRoute2" {
  destination_cidr_block         = "${var.dev_vpc_cidr}"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.DevVPCtoTransitGateway.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TransitGatewayExternalRouteTable.id
}


#
resource "aws_route" "ManagementPrivateSubnet1Route1" {
  route_table_id            = aws_route_table.mgmt_rt_pvtsub1.id
  destination_cidr_block    = "${var.prod_vpc_cidr}"
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.ManagementVPCtoTransitGateway, aws_route_table.mgmt_rt_pvtsub1,
  ]
}

resource "aws_route" "ManagementPrivateSubnet1Route2" {
  route_table_id            = aws_route_table.mgmt_rt_pvtsub1.id
  destination_cidr_block    = "${var.dev_vpc_cidr}"
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.ManagementVPCtoTransitGateway, aws_route_table.mgmt_rt_pvtsub1,
  ]
}

resource "aws_route" "ManagementPrivateSubnet2Route1" {
  route_table_id            = aws_route_table.mgmt_rt_pvtsub2.id
  destination_cidr_block    = "${var.prod_vpc_cidr}"
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.ManagementVPCtoTransitGateway, aws_route_table.mgmt_rt_pvtsub2,
  ]
}

resource "aws_route" "ManagementPrivateSubnet2Route2" {
  route_table_id            = aws_route_table.mgmt_rt_pvtsub2.id
  destination_cidr_block    = "${var.dev_vpc_cidr}"
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.ManagementVPCtoTransitGateway, aws_route_table.mgmt_rt_pvtsub2,
  ]
}

#
resource "aws_route" "ManagementPublicSubnet1Route1" {
  route_table_id            = aws_route_table.mgmt_rt_pubsub1.id
  destination_cidr_block    = "${var.prod_vpc_cidr}"
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.ManagementVPCtoTransitGateway, aws_route_table.mgmt_rt_pubsub1,
  ]
}

resource "aws_route" "ManagementPublicSubnet1Route2" {
  route_table_id            = aws_route_table.mgmt_rt_pubsub1.id
  destination_cidr_block    = "${var.dev_vpc_cidr}"
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.ManagementVPCtoTransitGateway, aws_route_table.mgmt_rt_pubsub1,
  ]
}

resource "aws_route" "ManagementPublicSubnet2Route1" {
  route_table_id            = aws_route_table.mgmt_rt_pubsub2.id
  destination_cidr_block    = "${var.prod_vpc_cidr}"
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.ManagementVPCtoTransitGateway, aws_route_table.mgmt_rt_pubsub2,
  ]
}

resource "aws_route" "ManagementPublicSubnet2Route2" {
  route_table_id            = aws_route_table.mgmt_rt_pubsub2.id
  destination_cidr_block    = "${var.dev_vpc_cidr}"
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.ManagementVPCtoTransitGateway, aws_route_table.mgmt_rt_pubsub2,
  ]
}

#
resource "aws_route" "DevelopmentVPCDefaultRoute" {
  route_table_id            = aws_route_table.rt_pvtsub1.id
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.DevVPCtoTransitGateway, aws_route_table.rt_pvtsub1,
  ]
}

resource "aws_route" "ProductionVPCDefaultRoute" {
  route_table_id            = aws_route_table.prod_rt_pvtsub1.id
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway.test_hipaa_transit_gateway.id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.ProductionVPCtoTransitGateway, aws_route_table.prod_rt_pvtsub1,
  ]
}