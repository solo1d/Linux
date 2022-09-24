### 适用版本openssl_2.3x

### 目录

- [AES加密方式](#AES加密方式)
  - [AES加密生成随机密钥](#AES加密生成随机密钥)
  - [AES加密](#AES加密)
  - [AES解密](#AES解密)
- [RSA加密方式](#RSA加密方式)
  - [AES加密生成随机密钥](#AES加密生成随机密钥)
  - [RSA加密](#RSA加密)
  - [RSA解密](#RSA解密)

# AES加密方式

## AES加密生成随机密钥

```bash
生成随机十六进制数字， 加解密都需要这两个密钥

密钥 key：长度 32  、  32nums(hexdec)
openssl rand -hex 32

初始向量 iv：长度 16  、 16nums(hexdex)
openssl rand -hex 16
```

## AES加密

```bash
# AES 加密 ， 先生成 随机32位密钥 和16位向量
# 记得使用生成的 key 和 iv，替换命令中的 32nums(hexdec) 和 16nums(hexdex)
openssl enc -aes-256-cbc -in example.file -out example.file.enc -base64 -K 32nums(hexdec) -iv 16nums(hexdec)

## 范例 ，压缩包名称 20220823.tar.gz， 加密后的文件 20220823.tar.gz.enc
#  得到初始化 32nums(hexdec)
#   执行： openssl rand -hex 32  输出：63ea08531681d557f40ece43beed79d0962f44a378f4f92c7662d7ca44d93b5b
#  得到初始化 16nums(hexdec)
#   执行： openssl rand -hex 16  输出：f2f8d8b0b6f85f45b077d59adbfa0fec
## 执行加密
openssl enc -aes-256-cbc -in 20220823.tar.gz -out 20220823.tar.gz.enc -base64 -K  63ea08531681d557f40ece43beed79d0962f44a378f4f92c7662d7ca44d93b5b -iv  f2f8d8b0b6f85f45b077d59adbfa0fec


# 执行解密 , 加密的压缩包名称 20220823.tar.gz.enc， 解密后的文件 20220823.tar.gz
openssl enc -aes-256-cbc -d -in 20220823.tar.gz.enc -base64 -out 20220823.tar.gz -K 63ea08531681d557f40ece43beed79d0962f44a378f4f92c7662d7ca44d93b5b -iv f2f8d8b0b6f85f45b077d59adbfa0fec
```

## AES解密

```bash
# AES 解密
# 记得使用密码文件中的 key 和 iv，替换命令中的 32nums(hexdec) 和 16nums(hexdex)

openssl enc -aes-256-cbc -d -in example.file.enc -base64 -out example.file.dec -K 32nums(hexdec) -iv 16nums(hexdec)

## 范例
#  得到加密时用到的 key 密钥 32nums(hexdec) :
#			63ea08531681d557f40ece43beed79d0962f44a378f4f92c7662d7ca44d93b5b
#  得到加密时用到的 iv 密钥 16nums(hexdec) :
#   	2f8d8b0b6f85f45b077d59adbfa0fec
# 执行解密 , 加密的压缩包名称 20220823.tar.gz.enc， 解密后的文件 20220823.tar.gz
openssl enc -aes-256-cbc -d -in 20220823.tar.gz.enc -base64 -out 20220823.tar.gz -K 63ea08531681d557f40ece43beed79d0962f44a378f4f92c7662d7ca44d93b5b -iv f2f8d8b0b6f85f45b077d59adbfa0fec
```

# RSA加密方式

==**该方式无法加密大文件，只能加密117字节的文件**==

**可以搭配RSA和AES来加密大文件,只加密生成的32和16位的密码key**

## 创建RSA私钥和公钥

```bash
生成私钥并写入到文件 rsa-private-key.pem，私钥长度为 4096 numbits
openssl genrsa -out rsa-private-key.pem 4096

根据私钥 rsa-private-key.pem 生成公钥，并写入到文件 rsa-public-key.pem
openssl rsa -in rsa-private-key.pem -pubout -out rsa-public-key.pem
```

## RSA加密

```bash
使用公钥 rsa-public-key.pem 加密文件 example.file 后生成 example.file.enc
openssl rsautl -encrypt -inkey rsa-public-key.pem -pubin -in example.file -out example.file.enc
```

## RSA解密

```bash
使用私钥 rsa-private-key.pem 解密文件 example.file.enc 为 example.file.dec
openssl rsautl -decrypt -inkey rsa-private-key.pem -in example.file.enc > example.file.dec

```

