###############################################################
# IAM Access Analyzer
###############################################################

module "access_analyzer" {

  source = "../modules/access-analyzer"

  analyzer_name = local.access_analyzer_name

  type = "ACCOUNT"

  tags = local.common_tags

}