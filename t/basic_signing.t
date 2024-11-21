use Test::Nginx::Socket 'no_plan';

run_tests();

__DATA__

=== Test Unsigned-Payload Signing:
--- main_config
env AWS_ACCESS_KEY_ID=XXXXX;
env AWS_SECRET_ACCESS_KEY=YYYYY;

--- http_config
    init_worker_by_lua_block {
        print("init")
    }

--- config
    location = /t {
        access_by_lua_block {
            local aws = require('resty.aws-signature')
            aws.aws_set_headers_detailed('example.com', ngx.var.uri, 'us-east-1', 's3', 'UNSIGNED-PAYLOAD', 1732156539)
        }

        content_by_lua_block {
            -- Dump all the request headers and turn them into response headers
            local h, err = ngx.req.get_headers()

            for k, v in pairs(h) do
                ngx.header[k] = v
            end

            ngx.print('ok')
        }
    }
--- request
GET /t
--- response_body chomp
ok
--- no_error_log
[error]
--- response_headers
Authorization: AWS4-HMAC-SHA256 Credential=XXXXX/20241121/us-east-1/s3/aws4_request,SignedHeaders=host;x-amz-content-sha256;x-amz-date,Signature=158e1fc160922a2b29b75ff169866a0f806bad69f85d71f673681fa2de8b4eec
Host: example.com
x-amz-date: 20241121T023539Z
x-amz-content-sha256: UNSIGNED-PAYLOAD


=== Test Signed-Payload Signing:
--- main_config
env AWS_ACCESS_KEY_ID=XXXXX;
env AWS_SECRET_ACCESS_KEY=YYYYY;

--- http_config
    init_worker_by_lua_block {
        print("init")
    }

--- config
    location = /t {
        access_by_lua_block {
            local aws = require('resty.aws-signature')
            aws.aws_set_headers_detailed('example.com', ngx.var.uri, 'us-east-1', 's3', 'b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c', 1732156539)
        }

        content_by_lua_block {
            -- Dump all the request headers and turn them into response headers
            local h, err = ngx.req.get_headers()

            for k, v in pairs(h) do
                ngx.header[k] = v
            end

            ngx.print('ok')
        }
    }
--- request
GET /t
--- response_body chomp
ok
--- no_error_log
[error]
--- response_headers
Authorization: AWS4-HMAC-SHA256 Credential=XXXXX/20241121/us-east-1/s3/aws4_request,SignedHeaders=host;x-amz-content-sha256;x-amz-date,Signature=14e366e10d1fcea41a6ef10afee718f01661561c4c4e888327b12d34c81f6dac
Host: example.com
x-amz-date: 20241121T023539Z
x-amz-content-sha256: b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c
