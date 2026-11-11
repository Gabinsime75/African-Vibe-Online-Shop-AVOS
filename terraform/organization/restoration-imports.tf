# AVOS restoration — recover Terraform ownership of existing resources.
# These imports do not authorize changes to the organization hierarchy.

import {
  to = aws_organizations_organizational_unit.top_level["security"]
  id = "ou-2tht-b2dt1xui"
}

import {
  to = aws_organizations_organizational_unit.top_level["infrastructure"]
  id = "ou-2tht-dtp7e0ur"
}

import {
  to = aws_organizations_organizational_unit.top_level["workloads"]
  id = "ou-2tht-1hz93sp2"
}

import {
  to = aws_organizations_organizational_unit.top_level["sandbox"]
  id = "ou-2tht-60egg5fx"
}

import {
  to = aws_organizations_organizational_unit.top_level["policy_staging"]
  id = "ou-2tht-vdyfw415"
}

import {
  to = aws_organizations_organizational_unit.top_level["suspended"]
  id = "ou-2tht-8rlhzq6h"
}

import {
  to = aws_organizations_organizational_unit.workload["development"]
  id = "ou-2tht-mcqkhm5w"
}

import {
  to = aws_organizations_organizational_unit.workload["staging"]
  id = "ou-2tht-f7c6n7nc"
}

import {
  to = aws_organizations_organizational_unit.workload["production"]
  id = "ou-2tht-lr5yp0ll"
}

import {
  to = aws_organizations_policy.deny_leave_organization
  id = "p-lfhh5k5p"
}

import {
  to = aws_organizations_policy_attachment.deny_leave_organization_policy_staging
  id = "ou-2tht-vdyfw415:p-lfhh5k5p"
}
