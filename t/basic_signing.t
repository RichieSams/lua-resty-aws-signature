use Test::Nginx::Socket 'no_plan';

run_tests();

__DATA__

=== Test Unsigned-Payload:
--- main_config
env AWS_ACCESS_KEY_ID=XXXXX;
env AWS_SECRET_ACCESS_KEY=YYYYY;

--- config
    location = /t {
        content_by_lua_block {
            local aws = require('resty.aws-signature')

            -- Calculate the headers and stuff them into the response
            h = aws.aws_signed_headers_detailed('example.com', '/foo/bar', 'us-east-1', 's3', 'UNSIGNED-PAYLOAD', 1732156539)
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
Authorization: AWS4-HMAC-SHA256 Credential=XXXXX/20241121/us-east-1/s3/aws4_request,SignedHeaders=host;x-amz-content-sha256;x-amz-date,Signature=75f899ff89e8248368c29bba4020d006613aa557ed0b492af19f118b8c7d9f65
Host: example.com
x-amz-date: 20241121T023539Z
x-amz-content-sha256: UNSIGNED-PAYLOAD


=== Test Signed-Payload:
--- main_config
env AWS_ACCESS_KEY_ID=XXXXX;
env AWS_SECRET_ACCESS_KEY=YYYYY;

--- config
    location = /t {
        content_by_lua_block {
            local aws = require('resty.aws-signature')

            -- Calculate the headers and stuff them into the response
            h = aws.aws_signed_headers_detailed('example.com', '/foo/bar', 'us-east-1', 's3', 'b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c', 1732156539)
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
Authorization: AWS4-HMAC-SHA256 Credential=XXXXX/20241121/us-east-1/s3/aws4_request,SignedHeaders=host;x-amz-content-sha256;x-amz-date,Signature=edb2f1da721ae556bed1dbec0e9345241451d49c5ba2be0f89e7d08f8f32728d
Host: example.com
x-amz-date: 20241121T023539Z
x-amz-content-sha256: b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c
