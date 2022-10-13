###########################################################################################################################################
#
#  SQS QUEUE FUNCTION
#
###########################################################################################################################################

resource "aws_sqs_queue" "sqs_queue" {
  name                      = var.queue_name
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
  /*redrive_policy = jsonencode({
    deadLetterTargetArn = local.dlqDestinationArn
    maxReceiveCount     = 30
  })*/

  tags = {
    Environment = "Production"
  }
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.sqs_queue.id

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.account_id}:root"
      },
      "Action": "SQS:*",
      "Resource": "${aws_sqs_queue.sqs_queue.arn}"
    },
    {
      "Sid": "__sender_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.task_role_arn_publisher}"
      },
      "Action": "SQS:SendMessage",
      "Resource": "${aws_sqs_queue.sqs_queue.arn}"
    },
    {
      "Sid": "__receiver_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.task_role_arn_consumer}"
      },
      "Action": [
        "SQS:ChangeMessageVisibility",
        "SQS:DeleteMessage",
        "SQS:ReceiveMessage"
      ],
      "Resource": "${aws_sqs_queue.sqs_queue.arn}"
    }
  ]
}
POLICY
}

###########################################################################################################################################
#
#  Função do IAM para que o API Gateway tenha as permissões necessárias para SendMessage em nossa fila SQS
#
###########################################################################################################################################

resource "aws_iam_role" "api_gateway_sqs_role" {
  name = "${var.queue_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "api_gateway_sqs_policy" {
  name = "${var.queue_name}-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility",
          "sqs:ListDeadLetterSourceQueues",
          "sqs:SendMessageBatch",
          "sqs:PurgeQueue",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
          "sqs:CreateQueue",
          "sqs:ListQueueTags",
          "sqs:ChangeMessageVisibilityBatch",
          "sqs:SetQueueAttributes"
        ],
        "Resource": "${aws_sqs_queue.sqs_queue.arn}"
      },
      {
        "Effect": "Allow",
        "Action": "sqs:ListQueues",
        "Resource": "*"
      }      
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.api_gateway_sqs_role.name
  policy_arn = aws_iam_policy.api_gateway_sqs_policy.arn
}

###########################################################################################################################################
#
#  CRIAÇÃO API KEY
#
###########################################################################################################################################

resource "aws_api_gateway_api_key" "api_gateway_api_key" {
  name         = "${var.queue_name}-api-key"
  description  = "apy key for > ${var.queue_name}"
  enabled      = "true"
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_gateway_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.sqs_integration_usage_plan.id
}


###########################################################################################################################################
#
#  CRIAÇÃO USAGE PLAN
#
###########################################################################################################################################

resource "aws_api_gateway_usage_plan" "sqs_integration_usage_plan" {
  name         = "${var.queue_name}-usage-plan"
  description  = "usage plan for > ${var.queue_name}"
  #product_code = "MYCODE"

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
    stage  = aws_api_gateway_stage.sqs_integration_stage.stage_name
  }

 # Rate Limit BY Weekly
/*
  quota_settings {
    limit  = 20
    offset = 2
    period = "WEEK"
  }
*/
  throttle_settings {
    burst_limit = 100
    rate_limit  = 100
  }
}

###########################################################################################################################################
#
#  CRIAÇÃO DO STAGE
#
###########################################################################################################################################


resource "aws_api_gateway_stage" "sqs_integration_stage" {
  deployment_id = aws_api_gateway_deployment.api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_rest_api.id
  stage_name    = "${var.queue_name}-stage"
  #web_acl_arn   = "waf.arn"
}

###########################################################################################################################################
#
#  CRIAÇÃO REST API GATEWAY
#
###########################################################################################################################################

resource "aws_api_gateway_rest_api" "api_gateway_rest_api" {
  name        = "${var.queue_name}"
  description = "Api Gateway integration with SQS :)"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

}

###########################################################################################################################################
#
#  CRIAÇÃO DO MÉTODO
#
###########################################################################################################################################

resource "aws_api_gateway_method" "api_gateway_method" {
  rest_api_id          = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id          = aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id
  api_key_required     = true
  http_method          = "POST"
  authorization        = "NONE"
  /*request_validator_id = "${aws_api_gateway_request_validator.api.id}"

  request_models = {
    "application/json" = "${aws_api_gateway_model.api.name}"
  }
*/

}

###########################################################################################################################################
#
#  CRIAÇÃO DA INTEGRAÇÃO 
#
###########################################################################################################################################

resource "aws_api_gateway_integration" "api_gateway_integration_sqs" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id             = aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id
  http_method             = "POST"
  type                    = "AWS"
  integration_http_method = "POST"
  passthrough_behavior    = "NEVER"
  credentials             = aws_iam_role.api_gateway_sqs_role.arn
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${aws_sqs_queue.sqs_queue.name}"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }
}

###########################################################################################################################################
#
#  CRIAÇÃO INTEGRATION RESPONSE
#
###########################################################################################################################################

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id       = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id       = aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id
  http_method       = aws_api_gateway_method.api_gateway_method.http_method
  status_code       = aws_api_gateway_method_response.method_response_200.status_code
  selection_pattern = "^2[0-9][0-9]"                                       // regex pattern for any 200 message that comes back from SQS

  response_templates = {
    "application/json" = "{\"message\": \"Sucesso! :)\"}"
  }

  depends_on = [aws_api_gateway_integration.api_gateway_integration_sqs]
}

resource "aws_api_gateway_method_response" "method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id
  http_method = aws_api_gateway_method.api_gateway_method.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }
}

###########################################################################################################################################
#
#  CRIAÇÃO API DEPLOYMENT
#
###########################################################################################################################################

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  stage_name  = "${var.queue_name}-stage"

  depends_on = [aws_api_gateway_integration.api_gateway_integration_sqs]
}

###########################################################################################################################################
#
#  CRIAÇÃO API DEPLOYMENT
#
###########################################################################################################################################


resource "aws_api_gateway_domain_name" "api_domain_name" {
  domain_name     = "${var.api_domain_name}"
  regional_certificate_arn = "${var.ssl}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
