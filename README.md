# s3cmd

A drop-in replacement for https://github.com/s3tools/s3cmd written in Ziglang for better performance and bootstrappability.

> Command line tool for querying and managing Amazon S3 services.

## What is Amazon S3

Amazon Simple Storage Service (Amazon S3) provides a managed internet-accessible storage service where anyone can store any amount of data and retrieve it later again.

S3 is a paid service operated by Amazon. Before storing anything into S3 you must sign up for an "AWS" account (where AWS = Amazon Web Services) to obtain a pair of identifiers: Access Key and Secret Key. You will need to give these keys to S3cmd. Think of them as if they were a username and password for your S3 account.

# Built With

- Zig 0.10.0
- See [`zigmod.yml`](./zigmod.yml) and [`zigmod.lock`](./zigmod.lock)

## Supported Commands

- [ ] `s3cmd mb`
- [ ] `s3cmd rb`
- [x] `s3cmd ls`
- [ ] `s3cmd la`
- [ ] `s3cmd put`
- [ ] `s3cmd get`
- [ ] `s3cmd del`
- [ ] `s3cmd rm`
- [ ] `s3cmd restore`
- [ ] `s3cmd sync`
- [ ] `s3cmd du`
- [ ] `s3cmd info`
- [ ] `s3cmd cp`
- [ ] `s3cmd modify`
- [ ] `s3cmd mv`
- [ ] `s3cmd setacl`
- [ ] `s3cmd setpolicy`
- [ ] `s3cmd delpolicy`
- [ ] `s3cmd setcors`
- [ ] `s3cmd delcors`
- [ ] `s3cmd payer`
- [ ] `s3cmd multipart`
- [ ] `s3cmd abortmp`
- [ ] `s3cmd listmp`
- [ ] `s3cmd accesslog`
- [ ] `s3cmd sign`
- [ ] `s3cmd signurl`
- [ ] `s3cmd fixbucket`
- [ ] `s3cmd ws-create`
- [ ] `s3cmd ws-delete`
- [ ] `s3cmd ws-info`
- [ ] `s3cmd expire`
- [ ] `s3cmd setlifecycle`
- [ ] `s3cmd getlifecycle`
- [ ] `s3cmd dellifecycle`
