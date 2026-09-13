#############################################
# GuardDuty Detector
#############################################

resource "aws_guardduty_detector" "this" {

  enable = var.enable

  finding_publishing_frequency = var.finding_publishing_frequency

  datasources {

    s3_logs {

      enable = var.datasources.s3_logs

    }

    kubernetes {

      audit_logs {

        enable = var.datasources.kubernetes.audit_logs

      }

    }

    malware_protection {

      scan_ec2_instance_with_findings {

        ebs_volumes {

          enable = var.datasources.malware_protection.scan_ec2_instance_with_findings

        }

      }

    }

  }

  tags = var.tags

}