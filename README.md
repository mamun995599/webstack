[Uploading webstack_documentation_bn_eng.md…]()
# ওয়েবস্ট্যাক পোর্টেবল ওয়েব সার্ভার

## সম্পূর্ণ ডকুমেন্টেশন ও ব্যবহারকারী ম্যানুয়াল

**সংস্করণ ২.০** | **সর্বশেষ আপডেট: ফেব্রুয়ারি ২০২৪**

---

# সূচিপত্র

১. [পরিচিতি](#১-পরিচিতি)
২. [সিস্টেম প্রয়োজনীয়তা](#২-সিস্টেম-প্রয়োজনীয়তা)
৩. [ইনস্টলেশন](#৩-ইনস্টলেশন)
৪. [ডিরেক্টরি কাঠামো](#৪-ডিরেক্টরি-কাঠামো)
৫. [দ্রুত শুরু](#৫-দ্রুত-শুরু)
৬. [কমান্ড রেফারেন্স](#৬-কমান্ড-রেফারেন্স)
৭. [উপাদানসমূহ](#৭-উপাদানসমূহ)
   - [Nginx](#৭১-nginx)
   - [PHP](#৭২-php)
   - [Node.js](#৭৩-nodejs)
   - [MySQL/MariaDB](#৭৪-mysqlmariadb)
   - [Redis](#৭৫-redis)
   - [Memcached](#৭৬-memcached)
   - [WebSocket](#৭৭-websocket)
   - [RTMP স্ট্রিমিং](#৭৮-rtmp-স্ট্রিমিং)
   - [Cloudflare Tunnel](#৭৯-cloudflare-tunnel)
   - [FFmpeg](#৭১০-ffmpeg)
   - [Composer](#৭১১-composer)
৮. [কনফিগারেশন](#৮-কনফিগারেশন)
৯. [ডেভেলপমেন্ট গাইড](#৯-ডেভেলপমেন্ট-গাইড)
১০. [প্রোডাকশন ডিপ্লয়মেন্ট](#১০-প্রোডাকশন-ডিপ্লয়মেন্ট)
১১. [ব্যাকআপ ও রিকভারি](#১১-ব্যাকআপ-ও-রিকভারি)
১২. [সমস্যা সমাধান](#১২-সমস্যা-সমাধান)
১৩. [নিরাপত্তা](#১৩-নিরাপত্তা)
১৪. [পারফরম্যান্স টিউনিং](#১৪-পারফরম্যান্স-টিউনিং)
১৫. [API রেফারেন্স](#১৫-api-রেফারেন্স)
১৬. [উদাহরণসমূহ](#১৬-উদাহরণসমূহ)
১৭. [সাধারণ প্রশ্নোত্তর](#১৭-সাধারণ-প্রশ্নোত্তর)
১৮. [পরিশিষ্ট](#১৮-পরিশিষ্ট)

---

# ১. পরিচিতি

## ১.১ ওয়েবস্ট্যাক কী?

ওয়েবস্ট্যাক হলো একটি **সম্পূর্ণ পোর্টেবল, স্বয়ংসম্পূর্ণ ওয়েব সার্ভার পরিবেশ** যা একটি মাত্র ডিরেক্টরি থেকে চলে এবং রুট/অ্যাডমিন অধিকার বা সিস্টেম-ওয়াইড ইনস্টলেশনের প্রয়োজন হয় না। এটি আধুনিক ওয়েব অ্যাপ্লিকেশন তৈরি এবং ডিপ্লয় করতে প্রয়োজনীয় সবকিছু সরবরাহ করে।

### মূল উপাদানসমূহ

| উপাদান | সংস্করণ | বর্ণনা |
|--------|---------|--------|
| **Nginx** | ১.২৫.৪ | HTTP/2, HTTP/3, RTMP সহ ওয়েব সার্ভার |
| **PHP** | ৮.৩.২ | ৫০+ এক্সটেনশন সহ PHP-FPM |
| **Node.js** | ২০.১০.০ | npm সহ জাভাস্ক্রিপ্ট রানটাইম |
| **MySQL** | MariaDB ১১.২ | ডাটাবেস সার্ভার |
| **Redis** | ৭.২.৪ | ইন-মেমরি ডাটা স্টোর |
| **Memcached** | ১.৬.২৩ | উচ্চ-কর্মক্ষমতা ক্যাশিং |
| **FFmpeg** | সর্বশেষ | মিডিয়া প্রসেসিং |
| **Cloudflared** | সর্বশেষ | পাবলিক অ্যাক্সেসের জন্য টানেল |

## ১.২ প্রধান বৈশিষ্ট্যসমূহ

| বৈশিষ্ট্য | বর্ণনা |
|----------|--------|
| **১০০% পোর্টেবল** | সম্পূর্ণ স্ট্যাক `~/webstack` থেকে চলে - যেকোনো জায়গায় কপি করুন |
| **রুট প্রয়োজন নেই** | সাধারণ ব্যবহারকারী হিসেবে চলে (পোর্ট ৮০/৪৪৩ ছাড়া) |
| **স্বয়ংসম্পূর্ণ** | সব ডিপেন্ডেন্সি বিল্ট-ইন, সিস্টেম লাইব্রেরি প্রয়োজন নেই |
| **HTTP/3 প্রস্তুত** | দ্রুত সংযোগের জন্য QUIC প্রোটোকল সমর্থন |
| **লাইভ স্ট্রিমিং** | HLS আউটপুট সহ RTMP/RTMPS ইনজেস্ট |
| **তাৎক্ষণিক পাবলিক URL** | অটো-রিকানেক্ট সহ Cloudflare টানেল |
| **আধুনিক ক্যাশিং** | PHP এক্সটেনশন সহ Redis এবং Memcached |
| **রিয়েল-টাইম** | WebSocket এবং Server-Sent Events সমর্থন |
| **PHP ৮.৩** | JIT, OPcache, সব এক্সটেনশন সহ সর্বশেষ PHP |

## ১.৩ আর্কিটেকচার ওভারভিউ

<details>
<summary><strong>💻 Code Block — 33 lines</strong></summary>

```
┌─────────────────────────────────────────────────────────────────────┐
│                            ইন্টারনেট                                 │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │    Cloudflare Tunnel      │
                    │  (র‍্যান্ডম পাবলিক HTTPS)    │
                    └─────────────┬─────────────┘
                                  │
┌─────────────────────────────────┴───────────────────────────────────┐
│                            NGINX                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │ HTTP:80  │  │HTTPS:443 │  │RTMP:1935 │  │RTMPS:1936│            │
│  │  HTTP/2  │  │  HTTP/3  │  │   লাইভ   │  │  সিকিউর  │            │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘            │
└───────┼─────────────┼─────────────┼─────────────┼───────────────────┘
        │             │             │             │
   ┌────┴────┐   ┌────┴────┐   ┌────┴────┐       │
   ▼         ▼   ▼         ▼   ▼         │       │
┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐   │       │
│ PHP  │  │Node  │  │  WS  │  │ HLS  │◄──┘       │
│ FPM  │  │ .js  │  │সার্ভার│  │আউটপুট│           │
└──┬───┘  └──┬───┘  └──────┘  └──────┘           │
   │         │                                    │
   └────┬────┘                                    │
        │                                         │
   ┌────┴────────────────────────────────────────┐
   │              ডাটা লেয়ার                      │
   │  ┌────────┐  ┌────────┐  ┌───────────┐     │
   │  │ MySQL  │  │ Redis  │  │ Memcached │     │
   │  │MariaDB │  │ :6379  │  │  :11211   │     │
   │  └────────┘  └────────┘  └───────────┘     │
   └──────────────────────────────────────────────┘
```

</details>

## ১.৪ ব্যবহারের ক্ষেত্রসমূহ

- **লোকাল ডেভেলপমেন্ট** - Docker বা VM ছাড়াই সম্পূর্ণ LAMP/LEMP স্ট্যাক
- **টেস্টিং** - অ্যাপ্লিকেশন টেস্টিংয়ের জন্য বিচ্ছিন্ন পরিবেশ
- **শিক্ষা** - ওয়েব ডেভেলপমেন্ট এবং সার্ভার অ্যাডমিনিস্ট্রেশন শেখা
- **পোর্টেবল প্রজেক্ট** - USB-তে আপনার সম্পূর্ণ ডেভ এনভায়রনমেন্ট বহন করুন
- **লাইভ স্ট্রিমিং** - RTMP/HLS সহ ব্যক্তিগত স্ট্রিমিং সার্ভার
- **ডেমো/প্রেজেন্টেশন** - Cloudflare টানেলের মাধ্যমে দ্রুত পাবলিক অ্যাক্সেস
- **মাইক্রোসার্ভিসেস** - PHP ব্যাকএন্ড সহ Node.js API
- **ক্যাশিং লেয়ার** - সেশন এবং ডাটা ক্যাশিংয়ের জন্য Redis/Memcached

---

# ২. সিস্টেম প্রয়োজনীয়তা

## ২.১ ন্যূনতম প্রয়োজনীয়তা

| উপাদান | ন্যূনতম | প্রস্তাবিত |
|--------|---------|------------|
| **অপারেটিং সিস্টেম** | Linux ৬৪-বিট | Ubuntu ২২.০৪+, Debian ১২+ |
| **CPU** | ২ কোর | ৪+ কোর |
| **RAM** | ২ GB | ৪+ GB |
| **ডিস্ক** | ৫ GB | ১০+ GB |
| **আর্কিটেকচার** | x86_64, ARM64 | x86_64 |

## ২.২ সমর্থিত অপারেটিং সিস্টেম

| অপারেটিং সিস্টেম | স্ট্যাটাস | নোট |
|-----------------|----------|------|
| Ubuntu ২০.০৪+ | ✅ সম্পূর্ণ সমর্থিত | প্রস্তাবিত |
| Debian ১০+ | ✅ সম্পূর্ণ সমর্থিত | |
| Linux Mint ২০+ | ✅ সম্পূর্ণ সমর্থিত | |
| CentOS ৭/৮/Stream | ✅ সমর্থিত | |
| Rocky Linux ৮/৯ | ✅ সমর্থিত | |
| AlmaLinux ৮/৯ | ✅ সমর্থিত | |
| Fedora ৩৬+ | ✅ সমর্থিত | |
| Arch Linux | ✅ সমর্থিত | |
| WSL2 | ✅ সমর্থিত | Windows ১০/১১ |
| macOS | ⚠️ আংশিক | পরিবর্তন প্রয়োজন |

## ২.৩ বিল্ড ডিপেন্ডেন্সি

সোর্স থেকে বিল্ড করার আগে এগুলো ইনস্টল করুন:

### Ubuntu/Debian

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
sudo apt update
sudo apt install -y \
    build-essential autoconf libtool pkg-config \
    git wget curl cmake ninja-build \
    libsqlite3-dev libreadline-dev libbz2-dev libgmp-dev \
    libxml2-dev libssl-dev libcurl4-openssl-dev \
    libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev \
    libonig-dev libzip-dev libsodium-dev libicu-dev
```

</details>

### CentOS/RHEL/Rocky/Alma

<details>
<summary><strong>💻 Code Block (bash) — 7 lines</strong></summary>

```bash
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y \
    autoconf libtool pkgconfig git wget curl cmake \
    sqlite-devel readline-devel bzip2-devel gmp-devel \
    libxml2-devel openssl-devel libcurl-devel \
    libpng-devel libjpeg-devel libwebp-devel freetype-devel \
    oniguruma-devel libzip-devel libsodium-devel libicu-devel
```

</details>

### Arch Linux

<details>
<summary><strong>💻 Code Block (bash) — 4 lines</strong></summary>

```bash
sudo pacman -S base-devel git wget curl cmake ninja \
    sqlite readline bzip2 gmp libxml2 openssl curl \
    libpng libjpeg-turbo libwebp freetype2 \
    oniguruma libzip libsodium icu
```

</details>

---

# ৩. ইনস্টলেশন

## ৩.১ দ্রুত ইনস্টল (প্রি-বিল্ট প্যাকেজ)

যদি আপনার কাছে প্রি-বিল্ট ওয়েবস্ট্যাক প্যাকেজ থাকে:

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# ১. প্যাকেজ এক্সট্র্যাক্ট করুন
tar -xzf webstack_portable_YYYYMMDD.tar.gz

# ২. ডিরেক্টরিতে প্রবেশ করুন
cd webstack

# ৩. ইনস্টলার চালান
./INSTALL.sh

# ৪. সব সার্ভিস শুরু করুন
./webstack start

# ৫. ব্রাউজার খুলুন
xdg-open http://localhost
```

</details>

## ৩.২ সোর্স থেকে বিল্ড করা (সম্পূর্ণ)

### ধাপ ১: পরিবেশ প্রস্তুত করা

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
# বেস ডিরেক্টরি তৈরি করুন
mkdir -p ~/webstack
cd ~/webstack

# ডিরেক্টরি কাঠামো তৈরি করুন
./setup_directories.sh
```

</details>

### ধাপ ২: Nginx ডিপেন্ডেন্সি বিল্ড করা

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./build_nginx_deps.sh
```

</details>

**যা বিল্ড হয়:** PCRE2, zlib, OpenSSL (QUIC সহ), libatomic_ops, libmaxminddb, libxml2, libxslt

**সময়:** ~১০-১৫ মিনিট

### ধাপ ৩: Nginx বিল্ড করা

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./build_nginx.sh
```

</details>

**বৈশিষ্ট্য:** HTTP/2, HTTP/3, RTMP, Push Stream, Brotli, GeoIP2, NJS

**সময়:** ~১০-১৫ মিনিট

### ধাপ ৪: PHP ডিপেন্ডেন্সি বিল্ড করা

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./build_php_deps.sh
```

</details>

**যা বিল্ড হয়:** সব ইমেজ লাইব্রেরি, এনক্রিপশন লাইব্রেরি, ICU, curl, hiredis, libmemcached

**সময়:** ~২০-৩০ মিনিট

### ধাপ ৫: PHP বিল্ড করা

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./build_php.sh
```

</details>

**বৈশিষ্ট্য:** Redis এবং Memcached সহ FPM, JIT, OPcache, ৫০+ এক্সটেনশন সহ PHP ৮.৩

**সময়:** ~১৫-২৫ মিনিট

### ধাপ ৬: Node.js ইনস্টল করা

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./install_node.sh
```

</details>

**সময়:** ~১ মিনিট

### ধাপ ৭: ঐচ্ছিক উপাদান ইনস্টল করা

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# MySQL/MariaDB ডাটাবেস
./setup_mysql.sh

# Redis ও Memcached (সার্ভার + PHP এক্সটেনশন)
./install_redis_memcached.sh

# Composer (PHP প্যাকেজ ম্যানেজার)
./setup_composer.sh

# FFmpeg (মিডিয়া প্রসেসিং)
./install_ffmpeg.sh

# Cloudflare Tunnel
./install_cloudflared.sh
```

</details>

### ধাপ ৮: কনফিগারেশন তৈরি করা

<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
# সব কনফিগ ফাইল তৈরি করুন
./setup.sh

# ম্যানেজমেন্ট স্ক্রিপ্ট তৈরি করুন
./create_scripts.sh
```

</details>

### ধাপ ৯: সার্ভিস শুরু করা

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./webstack start
```

</details>

## ৩.৩ ইনস্টলেশন যাচাই করা

<details>
<summary><strong>💻 Code Block (bash) — 20 lines</strong></summary>

```bash
# সব সার্ভিস চেক করুন
./webstack status

# HTTP টেস্ট করুন
curl http://localhost

# PHP টেস্ট করুন
curl http://localhost/index.php

# ক্যাশ টেস্ট করুন
curl http://localhost/test_cache.php

# API টেস্ট করুন
curl http://localhost/api/status

# উপাদান সংস্করণ
./php/bin/php -v
./node/bin/node -v
./nginx/sbin/nginx -v
./deps/bin/redis-server --version
```

</details>

## ৩.৪ বিল্ড স্ক্রিপ্ট রেফারেন্স

| স্ক্রিপ্ট | উদ্দেশ্য | সময় |
|----------|----------|------|
| `setup_directories.sh` | ডিরেক্টরি কাঠামো তৈরি | <১ মিনিট |
| `build_nginx_deps.sh` | Nginx ডিপেন্ডেন্সি বিল্ড | ১০-১৫ মিনিট |
| `build_nginx.sh` | Nginx সার্ভার বিল্ড | ১০-১৫ মিনিট |
| `build_php_deps.sh` | PHP ডিপেন্ডেন্সি বিল্ড | ২০-৩০ মিনিট |
| `build_php.sh` | এক্সটেনশন সহ PHP বিল্ড | ১৫-২৫ মিনিট |
| `install_node.sh` | Node.js ইনস্টল | <১ মিনিট |
| `setup_mysql.sh` | MariaDB ইনস্টল | ২-৩ মিনিট |
| `install_redis_memcached.sh` | Redis ও Memcached ইনস্টল | ৫-১০ মিনিট |
| `setup_composer.sh` | Composer ইনস্টল | <১ মিনিট |
| `install_ffmpeg.sh` | FFmpeg ইনস্টল | <১ মিনিট |
| `install_cloudflared.sh` | Cloudflare CLI ইনস্টল | <১ মিনিট |
| `setup.sh` | কনফিগারেশন তৈরি | <১ মিনিট |
| `create_scripts.sh` | ম্যানেজমেন্ট স্ক্রিপ্ট তৈরি | <১ মিনিট |

---

# ৪. ডিরেক্টরি কাঠামো

<details>
<summary><strong>💻 Code Block — 165 lines</strong></summary>

```
~/webstack/
│
├── webstack                 # মূল কন্ট্রোল স্ক্রিপ্ট ⭐
├── composer                 # Composer র‍্যাপার স্ক্রিপ্ট
├── setup.sh                 # কনফিগারেশন জেনারেটর
├── create_scripts.sh        # স্ক্রিপ্ট জেনারেটর
├── INSTALL.sh              # দ্রুত ইনস্টলার
├── cleanup.sh              # ক্লিনআপ স্ক্রিপ্ট
├── package.sh              # প্যাকেজিং স্ক্রিপ্ট
│
├── nginx/                   # Nginx ওয়েব সার্ভার
│   ├── sbin/
│   │   └── nginx           # Nginx বাইনারি
│   ├── conf/
│   │   ├── nginx.conf      # মূল কনফিগারেশন ⭐
│   │   ├── mime.types      # MIME টাইপস
│   │   ├── fastcgi_params  # FastCGI প্যারামিটার
│   │   ├── conf.d/         # অতিরিক্ত কনফিগ
│   │   │   └── *.conf      # ভার্চুয়াল হোস্ট
│   │   └── ssl/
│   │       ├── cert.pem    # SSL সার্টিফিকেট
│   │       └── key.pem     # SSL প্রাইভেট কী
│   ├── logs/
│   │   ├── access.log      # অ্যাক্সেস লগ
│   │   └── error.log       # এরর লগ
│   └── modules/            # ডায়নামিক মডিউল
│
├── php/                     # PHP ইনস্টলেশন
│   ├── bin/
│   │   ├── php             # PHP CLI
│   │   ├── phpize          # এক্সটেনশন বিল্ডার
│   │   ├── php-config      # কনফিগারেশন তথ্য
│   │   └── composer        # Composer বাইনারি
│   ├── sbin/
│   │   └── php-fpm         # PHP-FPM বাইনারি
│   ├── lib/
│   │   └── php/
│   │       └── extensions/ # এক্সটেনশন .so ফাইল
│   ├── etc/
│   │   ├── php.ini         # PHP কনফিগারেশন ⭐
│   │   ├── php-fpm.conf    # FPM কনফিগারেশন ⭐
│   │   ├── php-fpm.d/
│   │   │   └── www.conf    # পুল কনফিগারেশন
│   │   └── conf.d/         # এক্সটেনশন কনফিগ
│   │       ├── custom.ini
│   │       ├── ssl.ini
│   │       ├── redis.ini
│   │       └── memcached.ini
│   └── var/
│       ├── run/
│       │   └── php-fpm.pid
│       └── log/
│           ├── php-fpm.log
│           └── php-error.log
│
├── node/                    # Node.js ইনস্টলেশন
│   ├── bin/
│   │   ├── node            # Node.js বাইনারি
│   │   ├── npm             # npm প্যাকেজ ম্যানেজার
│   │   └── npx             # npm এক্সিকিউটর
│   └── lib/
│       └── node_modules/   # গ্লোবাল মডিউল
│
├── mysql/                   # MariaDB ইনস্টলেশন
│   ├── bin/
│   │   ├── mysql           # MySQL ক্লায়েন্ট
│   │   ├── mysqld          # MySQL সার্ভার
│   │   ├── mysqldump       # ব্যাকআপ টুল
│   │   └── mysqladmin      # অ্যাডমিন টুল
│   ├── lib/                # MySQL লাইব্রেরি
│   └── my.cnf              # MySQL কনফিগারেশন ⭐
│
├── redis/                   # Redis কনফিগারেশন
│   └── redis.conf          # Redis কনফিগারেশন ⭐
│
├── memcached/              # Memcached কনফিগারেশন
│   └── memcached.conf      # Memcached রেফারেন্স
│
├── deps/                    # শেয়ার্ড ডিপেন্ডেন্সি
│   ├── bin/
│   │   ├── openssl         # OpenSSL বাইনারি
│   │   ├── redis-server    # Redis সার্ভার ⭐
│   │   ├── redis-cli       # Redis CLI ⭐
│   │   ├── memcached       # Memcached সার্ভার ⭐
│   │   ├── ffmpeg          # FFmpeg বাইনারি
│   │   ├── ffprobe         # FFprobe বাইনারি
│   │   └── cloudflared     # Cloudflare টানেল
│   ├── lib/                # শেয়ার্ড লাইব্রেরি (.so)
│   └── ssl/
│       └── certs/
│           └── cacert.pem  # CA সার্টিফিকেট
│
├── www/                     # ওয়েব রুট ডিরেক্টরি ⭐
│   ├── index.html          # ডিফল্ট HTML পেজ
│   ├── index.php           # PHP টেস্ট পেজ
│   ├── phpinfo.php         # PHP ইনফো পেজ
│   ├── test_cache.php      # ক্যাশ টেস্ট পেজ ⭐
│   ├── app.js              # Node.js API সার্ভার
│   ├── phpmyadmin/         # phpMyAdmin
│   ├── hls/                # HLS স্ট্রিম আউটপুট
│   ├── videos/             # VOD ভিডিও
│   └── recordings/         # RTMP রেকর্ডিং
│
├── ws/                      # WebSocket সার্ভার
│   ├── server.js           # WebSocket সার্ভার স্ক্রিপ্ট
│   ├── package.json        # npm ডিপেন্ডেন্সি
│   └── node_modules/       # ইনস্টল করা মডিউল
│
├── data/                    # স্থায়ী ডাটা
│   ├── mysql/              # MySQL ডাটা ফাইল
│   └── redis/              # Redis পার্সিস্টেন্স
│
├── tmp/                     # রানটাইম ফাইল
│   ├── nginx.pid
│   ├── php-fpm.sock
│   ├── mysql.sock
│   ├── mysql.pid
│   ├── redis.pid
│   ├── memcached.pid
│   ├── node.pid
│   ├── ws.pid
│   ├── cloudflare_tunnel.pid
│   ├── cloudflare_monitor.pid
│   ├── cloudflare_url.txt  # বর্তমান টানেল URL
│   ├── sessions/           # PHP সেশন
│   ├── uploads/            # অস্থায়ী আপলোড
│   ├── client_body/        # Nginx ক্লায়েন্ট বডি
│   ├── proxy/              # Nginx প্রক্সি ক্যাশ
│   └── fastcgi/            # Nginx FastCGI ক্যাশ
│
├── logs/                    # লগ ফাইল
│   ├── node.log
│   ├── ws.log
│   ├── redis.log
│   ├── memcached.log
│   ├── mysql-error.log
│   └── cloudflare/
│       ├── tunnel.log
│       ├── cloudflared.log
│       └── url_history.log # সব টানেল URL ⭐
│
├── backups/                 # ব্যাকআপ ফাইল
│   ├── www_TIMESTAMP.tar.gz
│   ├── mysql_TIMESTAMP.sql.gz
│   └── config_TIMESTAMP.tar.gz
│
├── scripts/                 # ম্যানেজমেন্ট স্ক্রিপ্ট
│   ├── cloudflare_tunnel.sh
│   ├── start_redis.sh
│   ├── stop_redis.sh
│   ├── start_memcached.sh
│   ├── stop_memcached.sh
│   ├── start_mysql.sh
│   ├── stop_mysql.sh
│   ├── backup.sh
│   ├── renew_ssl.sh
│   ├── env.sh
│   ├── health.sh
│   └── logs.sh
│
└── src/                     # সোর্স ফাইল (অপসারণযোগ্য)
    ├── nginx-1.25.4/
    ├── php-8.3.2/
    ├── redis-7.2.4/
    └── ...
```

</details>

---

# ৫. দ্রুত শুরু

## ৫.১ সবকিছু শুরু করা

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
cd ~/webstack
./webstack start
```

</details>

**আউটপুট:**
<details>
<summary><strong>💻 Code Block — 9 lines</strong></summary>

```
Starting Redis... OK
Starting Memcached... OK
Starting PHP-FPM... OK
Starting Nginx... OK
Starting Node.js... OK
Starting WebSocket... OK
Starting MySQL... OK

WebStack started!
```

</details>

## ৫.২ স্ট্যাটাস চেক করা

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./webstack status
```

</details>

**আউটপুট:**
<details>
<summary><strong>💻 Code Block — 35 lines</strong></summary>

```
========================================
WebStack Status
========================================

Core Services:
  Nginx:       RUNNING (PID: 12345)
  PHP-FPM:     RUNNING (PID: 12346)
  Node.js:     RUNNING (PID: 12347)
  WebSocket:   RUNNING (PID: 12348)

Database:
  MySQL:       RUNNING (socket)

Cache Services:
  Redis:       RUNNING (port: 6379, v7.2.4)
  Memcached:   RUNNING (port: 11211)

PHP Cache Extensions:
  redis:       LOADED
  memcached:   LOADED

External Access:
  Cloudflare:  STOPPED

URLs:
  HTTP:       http://localhost
  HTTPS:      https://localhost
  RTMP:       rtmp://localhost:1935/live/streamkey
  RTMPS:      rtmps://localhost:1936/live/streamkey

Connection Info:
  MySQL:      socket: /home/user/webstack/tmp/mysql.sock
  Redis:      127.0.0.1:6379
  Memcached:  127.0.0.1:11211
  PHP-FPM:    /home/user/webstack/tmp/php-fpm.sock
```

</details>

## ৫.৩ আপনার সাইটে প্রবেশ করা

| URL | বর্ণনা |
|-----|--------|
| http://localhost | মূল ওয়েবসাইট (HTML) |
| http://localhost/index.php | PHP টেস্ট পেজ |
| http://localhost/test_cache.php | ক্যাশ টেস্ট (Redis/Memcached) |
| http://localhost/phpinfo.php | PHP তথ্য |
| http://localhost/phpmyadmin | ডাটাবেস ম্যানেজমেন্ট |
| http://localhost/api/status | Node.js API স্ট্যাটাস |
| ws://localhost/ws | WebSocket এন্ডপয়েন্ট |

## ৫.৪ পাবলিক অ্যাক্সেস সক্রিয় করা

<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
# অটো-রিকানেক্ট সহ টানেল শুরু করুন
./webstack tunnel daemon

# আপনার পাবলিক URL পান
./webstack tunnel url
```

</details>

**আউটপুট:**
<details>
<summary><strong>💻 Code Block — 1 lines</strong></summary>

```
https://random-words-here.trycloudflare.com
```

</details>

আপনার সাইট এখন HTTPS এর মাধ্যমে বিশ্বব্যাপী অ্যাক্সেসযোগ্য!

## ৫.৫ সবকিছু বন্ধ করা

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./webstack stop
```

</details>

---

# ৬. কমান্ড রেফারেন্স

## ৬.১ মূল কন্ট্রোল স্ক্রিপ্ট (`./webstack`)

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./webstack <command> [options]
```

</details>

### মূল কমান্ড

| কমান্ড | বর্ণনা |
|--------|--------|
| `start` | সব সার্ভিস শুরু করুন |
| `stop` | সব সার্ভিস বন্ধ করুন |
| `restart` | সব সার্ভিস রিস্টার্ট করুন |
| `status` | সব সার্ভিসের স্ট্যাটাস দেখুন |
| `logs` | সাম্প্রতিক লগ এন্ট্রি দেখুন |

### Cloudflare Tunnel কমান্ড

| কমান্ড | বর্ণনা |
|--------|--------|
| `tunnel start [port]` | টানেল শুরু করুন (ডিফল্ট পোর্ট ৮০) |
| `tunnel stop` | টানেল বন্ধ করুন |
| `tunnel restart` | টানেল রিস্টার্ট করুন (নতুন URL পান) |
| `tunnel daemon [port]` | অটো-রিকানেক্ট সহ শুরু করুন |
| `tunnel stop-daemon` | ডেমন বন্ধ করুন |
| `tunnel status` | টানেল স্ট্যাটাস দেখুন |
| `tunnel url` | বর্তমান URL দেখুন |
| `tunnel logs` | URL ইতিহাস দেখুন |

### ক্যাশ কমান্ড

| কমান্ড | বর্ণনা |
|--------|--------|
| `cache status` | ক্যাশ স্ট্যাটাস এবং পরিসংখ্যান দেখুন |
| `cache flush` | সব ক্যাশ ডাটা মুছুন |
| `cache start` | Redis এবং Memcached শুরু করুন |
| `cache stop` | Redis এবং Memcached বন্ধ করুন |
| `cache restart` | ক্যাশ সার্ভার রিস্টার্ট করুন |

### Redis কমান্ড

| কমান্ড | বর্ণনা |
|--------|--------|
| `redis start` | Redis সার্ভার শুরু করুন |
| `redis stop` | Redis সার্ভার বন্ধ করুন |
| `redis restart` | Redis সার্ভার রিস্টার্ট করুন |
| `redis cli [args]` | Redis CLI খুলুন বা কমান্ড চালান |

### Memcached কমান্ড

| কমান্ড | বর্ণনা |
|--------|--------|
| `memcached start` | Memcached সার্ভার শুরু করুন |
| `memcached stop` | Memcached সার্ভার বন্ধ করুন |
| `memcached restart` | Memcached সার্ভার রিস্টার্ট করুন |
| `memcached stats` | Memcached পরিসংখ্যান দেখুন |

### উদাহরণ

<details>
<summary><strong>💻 Code Block (bash) — 32 lines</strong></summary>

```bash
# সব সার্ভিস শুরু করুন
./webstack start

# সবকিছু চেক করুন
./webstack status

# লগ দেখুন
./webstack logs

# অটো-রিকানেক্ট সহ টানেল শুরু করুন
./webstack tunnel daemon

# বর্তমান টানেল URL পান
./webstack tunnel url

# ক্যাশ স্ট্যাটাস চেক করুন
./webstack cache status

# সব ক্যাশ ফ্লাশ করুন
./webstack cache flush

# Redis CLI ব্যবহার করুন
./webstack redis cli PING
./webstack redis cli SET mykey "hello"
./webstack redis cli GET mykey
./webstack redis cli INFO

# ইন্টারঅ্যাক্টিভ Redis CLI
./webstack redis cli

# Memcached স্ট্যাটস
./webstack memcached stats
```

</details>

## ৬.২ পৃথক সার্ভিস স্ক্রিপ্ট

### PHP কমান্ড

<details>
<summary><strong>💻 Code Block (bash) — 13 lines</strong></summary>

```bash
# PHP CLI
./php/bin/php -v                    # সংস্করণ
./php/bin/php -m                    # মডিউল তালিকা
./php/bin/php -i                    # PHP তথ্য
./php/bin/php script.php            # স্ক্রিপ্ট চালান
./php/bin/php -r "echo 'hello';"    # ইনলাইন কোড চালান

# PHP-FPM
./php/sbin/php-fpm -t               # কনফিগ টেস্ট করুন
./php/sbin/php-fpm -y /path/fpm.conf

# PHP-FPM রিলোড করুন (গ্রেসফুল)
kill -USR2 $(cat php/var/run/php-fpm.pid)
```

</details>

### Nginx কমান্ড

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# কনফিগারেশন টেস্ট করুন
./nginx/sbin/nginx -t -p ~/webstack/nginx

# কনফিগারেশন রিলোড করুন (গ্রেসফুল)
./nginx/sbin/nginx -p ~/webstack/nginx -s reload

# গ্রেসফুলি বন্ধ করুন
./nginx/sbin/nginx -p ~/webstack/nginx -s quit

# তাৎক্ষণিক বন্ধ করুন
./nginx/sbin/nginx -p ~/webstack/nginx -s stop

# সংস্করণ এবং মডিউল দেখুন
./nginx/sbin/nginx -V
```

</details>

### Node.js কমান্ড

<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# নোড চালান
./node/bin/node -v
./node/bin/node script.js

# npm ব্যবহার করুন (প্রজেক্ট ডিরেক্টরি থেকে)
cd ~/webstack/ws
../node/bin/node ../node/bin/npm install package-name
../node/bin/node ../node/bin/npm update
../node/bin/node ../node/bin/npm list
```

</details>

### MySQL কমান্ড

<details>
<summary><strong>💻 Code Block (bash) — 21 lines</strong></summary>

```bash
# শুরু/বন্ধ
./scripts/start_mysql.sh
./scripts/stop_mysql.sh

# MySQL ক্লায়েন্ট
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root

# পাসওয়ার্ড সহ
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root -p

# SQL কমান্ড চালান
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root -e "SHOW DATABASES;"

# ডাটাবেস ব্যাকআপ করুন
./mysql/bin/mysqldump --socket=./tmp/mysql.sock -u root dbname > backup.sql

# সব ডাটাবেস ব্যাকআপ করুন
./mysql/bin/mysqldump --socket=./tmp/mysql.sock -u root --all-databases > all.sql

# ডাটাবেস রিস্টোর করুন
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root dbname < backup.sql
```

</details>

### Redis কমান্ড

<details>
<summary><strong>💻 Code Block (bash) — 13 lines</strong></summary>

```bash
# সরাসরি Redis CLI
./deps/bin/redis-cli

# সাধারণ কমান্ড
./deps/bin/redis-cli PING
./deps/bin/redis-cli INFO
./deps/bin/redis-cli KEYS "*"
./deps/bin/redis-cli SET key value
./deps/bin/redis-cli GET key
./deps/bin/redis-cli DEL key
./deps/bin/redis-cli FLUSHALL
./deps/bin/redis-cli DBSIZE
./deps/bin/redis-cli MONITOR
```

</details>

### Memcached কমান্ড

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# netcat এর মাধ্যমে স্ট্যাটস
echo "stats" | nc localhost 11211

# সব ফ্লাশ করুন
echo "flush_all" | nc localhost 11211

# স্ট্যাটস আইটেম পান
echo "stats items" | nc localhost 11211
```

</details>

### Composer কমান্ড

<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# র‍্যাপার এর মাধ্যমে
./composer --version
./composer install
./composer update
./composer require vendor/package
./composer dump-autoload -o

# সরাসরি
./php/bin/php ./php/bin/composer install
```

</details>

### FFmpeg কমান্ড

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# সংস্করণ
./deps/bin/ffmpeg -version

# ভিডিও রূপান্তর করুন
./deps/bin/ffmpeg -i input.mp4 -c:v libx264 output.mp4

# RTMP তে স্ট্রিম করুন
./deps/bin/ffmpeg -re -i video.mp4 -c copy -f flv rtmp://localhost:1935/live/test
```

</details>

## ৬.৩ ইউটিলিটি স্ক্রিপ্ট

### এনভায়রনমেন্ট সেটআপ

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# এনভায়রনমেন্ট লোড করুন (সব পাথ যোগ করে)
source ./scripts/env.sh

# এখন কমান্ড সরাসরি ব্যবহার করুন
php -v
node -v
mysql -u root
redis-cli PING
```

</details>

### ব্যাকআপ

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./scripts/backup.sh
```

</details>

তৈরি করে:
- `backups/www_TIMESTAMP.tar.gz`
- `backups/mysql_TIMESTAMP.sql.gz`
- `backups/config_TIMESTAMP.tar.gz`

### হেলথ চেক

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./scripts/health.sh
```

</details>

### লগ ভিউয়ার

<details>
<summary><strong>💻 Code Block (bash) — 7 lines</strong></summary>

```bash
./scripts/logs.sh              # সব লগ
./scripts/logs.sh nginx        # শুধু Nginx
./scripts/logs.sh php          # শুধু PHP
./scripts/logs.sh node         # শুধু Node.js
./scripts/logs.sh mysql        # শুধু MySQL
./scripts/logs.sh redis        # শুধু Redis
./scripts/logs.sh cloudflare   # শুধু Cloudflare
```

</details>

### SSL সার্টিফিকেট নবায়ন

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./scripts/renew_ssl.sh
```

</details>

---

# ৭. উপাদানসমূহ

## ৭.১ Nginx

### সংস্করণ ও বৈশিষ্ট্য

| বৈশিষ্ট্য | স্ট্যাটাস |
|----------|----------|
| সংস্করণ | ১.২৫.৪ |
| HTTP/2 | ✅ সক্রিয় |
| HTTP/3 (QUIC) | ✅ সক্রিয় |
| TLS 1.3 | ✅ সক্রিয় |
| Brotli | ✅ সক্রিয় |
| GeoIP2 | ✅ সক্রিয় |
| RTMP | ✅ সক্রিয় |

### ইনস্টল করা মডিউল

| মডিউল | বর্ণনা |
|-------|--------|
| `http_ssl_module` | SSL/TLS সমর্থন |
| `http_v2_module` | HTTP/2 সমর্থন |
| `http_v3_module` | HTTP/3 (QUIC) সমর্থন |
| `http_realip_module` | হেডার থেকে রিয়েল IP |
| `http_gzip_static_module` | প্রি-কম্প্রেসড ফাইল |
| `http_mp4_module` | MP4 স্ট্রিমিং |
| `http_flv_module` | FLV স্ট্রিমিং |
| `http_secure_link_module` | সিকিউর লিংক |
| `http_stub_status_module` | বেসিক স্ট্যাটাস |
| `http_auth_request_module` | Auth সাবরিকোয়েস্ট |
| `stream_module` | TCP/UDP প্রক্সি |
| `nginx-rtmp-module` | RTMP স্ট্রিমিং |
| `push_stream_module` | Server-Sent Events |
| `headers-more-module` | হেডার ম্যানিপুলেশন |
| `ngx_brotli` | Brotli কম্প্রেশন |
| `ngx_cache_purge` | ক্যাশ পার্জিং |
| `nginx-module-vts` | ট্রাফিক স্ট্যাটাস |
| `njs` | JavaScript স্ক্রিপ্টিং |
| `ngx_http_geoip2_module` | GeoIP2 সমর্থন |

### কনফিগারেশন

**মূল কনফিগ:** `nginx/conf/nginx.conf`

**ভার্চুয়াল হোস্ট যোগ করুন:** `nginx/conf/conf.d/mysite.conf` তৈরি করুন

<details>
<summary><strong>💻 Code Block (nginx) — 16 lines</strong></summary>

```nginx
server {
    listen 80;
    server_name mysite.local;
    root /home/user/webstack/www/mysite;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/home/user/webstack/tmp/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

</details>

রিলোড করুন: `./nginx/sbin/nginx -p ~/webstack/nginx -s reload`

## ৭.২ PHP

### সংস্করণ ও কনফিগারেশন

| বৈশিষ্ট্য | মান |
|----------|-----|
| সংস্করণ | ৮.৩.২ |
| SAPI | FPM |
| JIT | ✅ সক্রিয় |
| OPcache | ✅ সক্রিয় |

### লোড করা এক্সটেনশন

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./php/bin/php -m
```

</details>

**কোর:** Core, date, filter, hash, json, pcre, Reflection, SPL, standard

**ডাটাবেস:** mysqli, mysqlnd, PDO, pdo_mysql, pdo_sqlite, sqlite3

**ক্যাশিং:** redis, memcached, opcache

**এনক্রিপশন:** openssl, sodium, password (argon2)

**কম্প্রেশন:** zlib, zip, bz2

**ইমেজ:** gd (freetype, jpeg, webp, png)

**XML:** dom, libxml, simplexml, xml, xmlreader, xmlwriter

**স্ট্রিং:** mbstring, iconv, intl, ctype, tokenizer

**নেটওয়ার্ক:** curl, sockets, ftp

**অন্যান্য:** bcmath, calendar, exif, fileinfo, pcntl, posix, readline, session

### কনফিগারেশন ফাইল

| ফাইল | উদ্দেশ্য |
|------|----------|
| `php/etc/php.ini` | মূল কনফিগারেশন |
| `php/etc/php-fpm.conf` | FPM গ্লোবাল কনফিগ |
| `php/etc/php-fpm.d/www.conf` | পুল কনফিগ |
| `php/etc/conf.d/custom.ini` | কাস্টম সেটিংস |
| `php/etc/conf.d/redis.ini` | Redis এক্সটেনশন |
| `php/etc/conf.d/memcached.ini` | Memcached এক্সটেনশন |

### গুরুত্বপূর্ণ php.ini সেটিংস

<details>
<summary><strong>💻 Code Block (ini) — 10 lines</strong></summary>

```ini
memory_limit = 256M
max_execution_time = 300
upload_max_filesize = 100M
post_max_size = 100M

opcache.enable = 1
opcache.jit = 1255
opcache.jit_buffer_size = 64M

date.timezone = UTC
```

</details>

## ৭.৩ Node.js

### সংস্করণ

| উপাদান | সংস্করণ |
|--------|---------|
| Node.js | ২০.১০.০ LTS |
| npm | ১০.x |

### npm ব্যবহার করা

<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# প্রজেক্টে নেভিগেট করুন
cd ~/webstack/ws

# প্যাকেজ ইনস্টল করুন
../node/bin/node ../node/bin/npm install express

# অথবা alias তৈরি করুন
alias npm="~/webstack/node/bin/node ~/webstack/node/bin/npm"
npm install ws
```

</details>

### ডিফল্ট API সার্ভার

অবস্থান: `www/app.js`

এন্ডপয়েন্ট:
- `GET /api/status` - সার্ভার স্ট্যাটাস
- `GET /api/health` - হেলথ চেক
- `POST /api/echo` - ইকো রিকোয়েস্ট
- `GET /api/events` - Server-Sent Events

### WebSocket সার্ভার

অবস্থান: `ws/server.js`

বৈশিষ্ট্য:
- ক্লায়েন্ট ট্র্যাকিং
- মেসেজ ব্রডকাস্টিং
- Ping/pong সমর্থন

## ৭.৪ MySQL/MariaDB

### সংস্করণ

MariaDB ১১.২.২

### কনফিগারেশন

অবস্থান: `mysql/my.cnf`

<details>
<summary><strong>💻 Code Block (ini) — 7 lines</strong></summary>

```ini
[mysqld]
socket = /home/user/webstack/tmp/mysql.sock
port = 3306
bind-address = 127.0.0.1
character-set-server = utf8mb4
max_connections = 100
innodb_buffer_pool_size = 128M
```

</details>

### কমান্ড

<details>
<summary><strong>💻 Code Block (bash) — 16 lines</strong></summary>

```bash
# শুরু/বন্ধ
./scripts/start_mysql.sh
./scripts/stop_mysql.sh

# সংযোগ করুন
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root

# ডাটাবেস তৈরি করুন
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root \
    -e "CREATE DATABASE myapp CHARACTER SET utf8mb4;"

# ব্যবহারকারী তৈরি করুন
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root \
    -e "CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'password';"
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root \
    -e "GRANT ALL ON myapp.* TO 'myuser'@'localhost';"
```

</details>

### PHP সংযোগ

<details>
<summary><strong>💻 Code Block (php) — 6 lines</strong></summary>

```php
// PDO ব্যবহার করে (প্রস্তাবিত)
$socket = '/home/user/webstack/tmp/mysql.sock';
$pdo = new PDO("mysql:unix_socket=$socket;dbname=myapp", 'root', '');

// mysqli ব্যবহার করে
$mysqli = new mysqli('localhost', 'root', '', 'myapp', 0, $socket);
```

</details>

### phpMyAdmin

অ্যাক্সেস: http://localhost/phpmyadmin

ডিফল্ট লগইন: `root` (পাসওয়ার্ড নেই)

## ৭.৫ Redis

### সংস্করণ

Redis ৭.২.৪

### কনফিগারেশন

অবস্থান: `redis/redis.conf`

<details>
<summary><strong>💻 Code Block (ini) — 5 lines</strong></summary>

```ini
bind 127.0.0.1
port 6379
daemonize yes
maxmemory 128mb
maxmemory-policy allkeys-lru
```

</details>

### কমান্ড

<details>
<summary><strong>💻 Code Block (bash) — 18 lines</strong></summary>

```bash
# webstack এর মাধ্যমে শুরু/বন্ধ
./webstack redis start
./webstack redis stop

# অথবা স্ক্রিপ্টের মাধ্যমে
./scripts/start_redis.sh
./scripts/stop_redis.sh

# Redis CLI
./webstack redis cli PING
./webstack redis cli INFO
./webstack redis cli SET key value
./webstack redis cli GET key

# ইন্টারঅ্যাক্টিভ
./webstack redis cli
# অথবা
./deps/bin/redis-cli
```

</details>

### PHP ব্যবহার

<details>
<summary><strong>💻 Code Block (php) — 39 lines</strong></summary>

```php
<?php
// সংযোগ করুন
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);

// বেসিক অপারেশন
$redis->set('key', 'value');
$redis->setex('temp', 3600, '১ ঘণ্টায় মেয়াদ শেষ');
$value = $redis->get('key');

// ইনক্রিমেন্ট
$redis->incr('counter');
$redis->incrBy('counter', 5);

// হ্যাশ
$redis->hSet('user:1', 'name', 'জন');
$redis->hSet('user:1', 'email', 'john@example.com');
$user = $redis->hGetAll('user:1');

// লিস্ট
$redis->rPush('queue', 'item1', 'item2');
$item = $redis->lPop('queue');

// সেট
$redis->sAdd('tags', 'php', 'redis', 'web');
$tags = $redis->sMembers('tags');

// সর্টেড সেট
$redis->zAdd('leaderboard', 100, 'player1');
$redis->zAdd('leaderboard', 200, 'player2');
$top = $redis->zRevRange('leaderboard', 0, 9, true);

// মেয়াদ
$redis->expire('key', 3600);
$ttl = $redis->ttl('key');

// মুছুন
$redis->del('key');
$redis->del(['key1', 'key2']);
```

</details>

### ক্যাশিং প্যাটার্ন

<details>
<summary><strong>💻 Code Block (php) — 18 lines</strong></summary>

```php
function getCached($key, $callback, $ttl = 3600) {
    global $redis;
    
    $value = $redis->get($key);
    
    if ($value === false) {
        $value = $callback();
        $redis->setex($key, $ttl, serialize($value));
        return $value;
    }
    
    return unserialize($value);
}

// ব্যবহার
$users = getCached('all_users', function() use ($pdo) {
    return $pdo->query('SELECT * FROM users')->fetchAll();
}, 300);
```

</details>

## ৭.৬ Memcached

### সংস্করণ

Memcached ১.৬.২৩

### কনফিগারেশন

শুরু কমান্ড এই ডিফল্ট ব্যবহার করে:
- মেমরি: ৬৪ MB
- পোর্ট: ১১২১১
- সংযোগ: ১০২৪

### কমান্ড

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# webstack এর মাধ্যমে শুরু/বন্ধ
./webstack memcached start
./webstack memcached stop

# অথবা স্ক্রিপ্টের মাধ্যমে
./scripts/start_memcached.sh
./scripts/stop_memcached.sh

# স্ট্যাটস
./webstack memcached stats
echo "stats" | nc localhost 11211

# ফ্লাশ
echo "flush_all" | nc localhost 11211
```

</details>

### PHP ব্যবহার

<details>
<summary><strong>💻 Code Block (php) — 38 lines</strong></summary>

```php
<?php
// সংযোগ করুন
$memcached = new Memcached();
$memcached->addServer('127.0.0.1', 11211);

// বেসিক অপারেশন
$memcached->set('key', 'value', 3600);
$value = $memcached->get('key');

// একাধিক কী
$memcached->setMulti([
    'key1' => 'value1',
    'key2' => 'value2'
], 3600);
$values = $memcached->getMulti(['key1', 'key2']);

// ইনক্রিমেন্ট
$memcached->set('counter', 0);
$memcached->increment('counter');
$memcached->increment('counter', 5);

// অ্যারে/অবজেক্ট সংরক্ষণ করুন
$memcached->set('user', ['name' => 'জন', 'email' => 'john@example.com']);
$user = $memcached->get('user');

// যোগ করুন (শুধুমাত্র যদি না থাকে)
$memcached->add('unique_key', 'value');

// প্রতিস্থাপন করুন (শুধুমাত্র যদি থাকে)
$memcached->replace('key', 'new_value');

// মুছুন
$memcached->delete('key');

// ফলাফল চেক করুন
if ($memcached->getResultCode() === Memcached::RES_SUCCESS) {
    echo "অপারেশন সফল";
}
```

</details>

### সেশন স্টোরেজ

<details>
<summary><strong>💻 Code Block (ini) — 3 lines</strong></summary>

```ini
; php.ini
session.save_handler = memcached
session.save_path = "127.0.0.1:11211"
```

</details>

## ৭.৭ WebSocket

### সার্ভার

অবস্থান: `ws/server.js`

পোর্ট: ৮০৮১ (Nginx এর মাধ্যমে `/ws` এ প্রক্সি করা)

### বৈশিষ্ট্য

- ক্লায়েন্ট ID অ্যাসাইনমেন্ট
- স্বাগত বার্তা
- মেসেজ ইকো
- সব ক্লায়েন্টে ব্রডকাস্ট
- ক্লায়েন্ট যোগদান/প্রস্থান নোটিফিকেশন
- Ping/pong সমর্থন

### ক্লায়েন্ট উদাহরণ

<details>
<summary><strong>💻 Code Block (html) — 32 lines</strong></summary>

```html
<!DOCTYPE html>
<html>
<head>
    <title>WebSocket টেস্ট</title>
</head>
<body>
    <input type="text" id="message" placeholder="বার্তা">
    <button onclick="send()">পাঠান</button>
    <div id="output"></div>

    <script>
        const ws = new WebSocket('ws://localhost/ws');
        
        ws.onopen = () => log('সংযুক্ত');
        
        ws.onmessage = (e) => {
            const data = JSON.parse(e.data);
            log('প্রাপ্ত: ' + JSON.stringify(data));
        };
        
        ws.onclose = () => log('সংযোগ বিচ্ছিন্ন');
        
        function send() {
            ws.send(document.getElementById('message').value);
        }
        
        function log(msg) {
            document.getElementById('output').innerHTML += '<p>' + msg + '</p>';
        }
    </script>
</body>
</html>
```

</details>

## ৭.৮ RTMP স্ট্রিমিং

### পোর্ট

| পোর্ট | প্রোটোকল | বর্ণনা |
|-------|----------|--------|
| ১৯৩৫ | RTMP | স্ট্যান্ডার্ড স্ট্রিমিং |
| ১৯৩৬ | RTMPS | সিকিউর স্ট্রিমিং (TLS) |

### স্ট্রিম URL

<details>
<summary><strong>💻 Code Block — 6 lines</strong></summary>

```
# ইনজেস্ট
rtmp://localhost:1935/live/STREAM_KEY
rtmps://localhost:1936/live/STREAM_KEY

# প্লেব্যাক (HLS)
http://localhost/hls/STREAM_KEY.m3u8
```

</details>

### OBS Studio সেটিংস

| সেটিং | মান |
|-------|-----|
| Service | Custom |
| Server | `rtmp://localhost:1935/live` |
| Stream Key | `mystream` |

### FFmpeg স্ট্রিমিং

<details>
<summary><strong>💻 Code Block (bash) — 13 lines</strong></summary>

```bash
# ভিডিও ফাইল স্ট্রিম করুন
./deps/bin/ffmpeg -re -i video.mp4 -c copy -f flv \
    rtmp://localhost:1935/live/test

# এনকোডিং সহ স্ট্রিম করুন
./deps/bin/ffmpeg -re -i video.mp4 \
    -c:v libx264 -preset veryfast -b:v 2500k \
    -c:a aac -b:a 128k \
    -f flv rtmp://localhost:1935/live/test

# লুপ স্ট্রিম
./deps/bin/ffmpeg -stream_loop -1 -re -i video.mp4 \
    -c copy -f flv rtmp://localhost:1935/live/test
```

</details>

### HLS প্লেব্যাক

<details>
<summary><strong>💻 Code Block (html) — 22 lines</strong></summary>

```html
<!DOCTYPE html>
<html>
<head>
    <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
</head>
<body>
    <video id="video" controls width="720"></video>
    
    <script>
        const video = document.getElementById('video');
        const streamUrl = '/hls/mystream.m3u8';
        
        if (Hls.isSupported()) {
            const hls = new Hls();
            hls.loadSource(streamUrl);
            hls.attachMedia(video);
        } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
            video.src = streamUrl;
        }
    </script>
</body>
</html>
```

</details>

## ৭.৯ Cloudflare Tunnel

### সংক্ষিপ্ত বিবরণ

নিম্নলিখিত ছাড়াই তাৎক্ষণিক পাবলিক HTTPS অ্যাক্সেস প্রদান করে:
- ফায়ারওয়াল পোর্ট খোলা
- পোর্ট ফরওয়ার্ডিং কনফিগার করা
- ডায়নামিক DNS সেটআপ করা
- SSL সার্টিফিকেট কেনা

### ইনস্টলেশন

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./install_cloudflared.sh
```

</details>

### কমান্ড

<details>
<summary><strong>💻 Code Block (bash) — 24 lines</strong></summary>

```bash
# সহজ শুরু
./webstack tunnel start

# অটো-রিকানেক্ট সহ (প্রস্তাবিত)
./webstack tunnel daemon

# বন্ধ করুন
./webstack tunnel stop
./webstack tunnel stop-daemon

# স্ট্যাটাস
./webstack tunnel status

# বর্তমান URL
./webstack tunnel url

# URL ইতিহাস
./webstack tunnel logs

# রিস্টার্ট করুন (নতুন URL)
./webstack tunnel restart

# কাস্টম পোর্ট
./webstack tunnel daemon 8080
```

</details>

### URL ইতিহাস

অবস্থান: `logs/cloudflare/url_history.log`

ফরম্যাট (নতুন প্রথমে):
<details>
<summary><strong>💻 Code Block — 3 lines</strong></summary>

```
2024-02-27 14:30:22 | https://random-words-here.trycloudflare.com
2024-02-27 12:15:10 | https://other-random-url.trycloudflare.com
2024-02-26 09:45:33 | https://previous-tunnel.trycloudflare.com
```

</details>

### অটো-রিকানেক্ট আচরণ

১. প্রতি ৩০ সেকেন্ডে টানেল হেলথ মনিটর করে
২. টানেল বন্ধ হলে, পুনঃসংযোগের চেষ্টা করে
৩. ৫টি ব্যর্থতার পর, নতুন URL সহ নতুন টানেল তৈরি করে
৪. সব URL ইতিহাস ফাইলে লগ করা হয়

## ৭.১০ FFmpeg

### ইনস্টলেশন

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./install_ffmpeg.sh
```

</details>

### সাধারণ অপারেশন

<details>
<summary><strong>💻 Code Block (bash) — 29 lines</strong></summary>

```bash
# সংস্করণ চেক করুন
./deps/bin/ffmpeg -version

# এনকোডার তালিকা দেখুন
./deps/bin/ffmpeg -encoders

# ভিডিও রূপান্তর করুন
./deps/bin/ffmpeg -i input.mp4 -c:v libx264 -c:a aac output.mp4

# অডিও এক্সট্র্যাক্ট করুন
./deps/bin/ffmpeg -i video.mp4 -vn -c:a mp3 audio.mp3

# থাম্বনেইল তৈরি করুন
./deps/bin/ffmpeg -i video.mp4 -ss 00:00:05 -vframes 1 thumb.jpg

# ভিডিও স্কেল করুন
./deps/bin/ffmpeg -i input.mp4 -vf scale=1280:720 output_720p.mp4

# HLS এ রূপান্তর করুন
./deps/bin/ffmpeg -i input.mp4 \
    -c:v libx264 -c:a aac \
    -hls_time 10 -hls_list_size 0 \
    -f hls output.m3u8

# ভিডিও কম্প্রেস করুন
./deps/bin/ffmpeg -i input.mp4 \
    -c:v libx264 -crf 23 \
    -c:a aac -b:a 128k \
    output_compressed.mp4
```

</details>

## ৭.১১ Composer

### ইনস্টলেশন

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./setup_composer.sh
```

</details>

### ব্যবহার

<details>
<summary><strong>💻 Code Block (bash) — 10 lines</strong></summary>

```bash
# র‍্যাপার এর মাধ্যমে (SSL সার্টিফিকেট হ্যান্ডেল করে)
./composer --version
./composer install
./composer update
./composer require monolog/monolog
./composer dump-autoload -o

# নতুন প্রজেক্ট তৈরি করুন
cd www
../composer create-project laravel/laravel myapp
```

</details>

---

# ৮. কনফিগারেশন

## ৮.১ Nginx কনফিগারেশন

### মূল কনফিগ: `nginx/conf/nginx.conf`

গুরুত্বপূর্ণ সেকশন:

<details>
<summary><strong>💻 Code Block (nginx) — 38 lines</strong></summary>

```nginx
# ওয়ার্কার সেটিংস
worker_processes auto;

# ইভেন্টস
events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

# HTTP সেটিংস
http {
    # কম্প্রেশন
    gzip on;
    gzip_types application/javascript text/css;
    
    # আপস্ট্রিম
    upstream php-fpm {
        server unix:/path/to/php-fpm.sock;
    }
    
    # সার্ভার ব্লক
    server {
        listen 80;
        # ...
    }
}

# RTMP
rtmp {
    server {
        listen 1935;
        application live {
            live on;
            hls on;
        }
    }
}
```

</details>

### ভার্চুয়াল হোস্ট যোগ করুন

`nginx/conf/conf.d/myapp.conf` তৈরি করুন:

<details>
<summary><strong>💻 Code Block (nginx) — 28 lines</strong></summary>

```nginx
server {
    listen 80;
    server_name myapp.local;
    root /home/user/webstack/www/myapp/public;
    index index.php index.html;

    # Laravel/Symfony রাউটিং
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass php-fpm;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # স্ট্যাটিক ফাইল ক্যাশিং
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # হিডেন ফাইল অস্বীকার করুন
    location ~ /\. {
        deny all;
    }
}
```

</details>

## ৮.২ PHP কনফিগারেশন

### php.ini: `php/etc/php.ini`

<details>
<summary><strong>💻 Code Block (ini) — 38 lines</strong></summary>

```ini
; রিসোর্স লিমিট
memory_limit = 256M
max_execution_time = 300
max_input_time = 300
max_input_vars = 5000

; আপলোড
upload_max_filesize = 100M
post_max_size = 100M
max_file_uploads = 50

; এরর হ্যান্ডলিং (ডেভেলপমেন্ট)
display_errors = On
error_reporting = E_ALL
log_errors = On

; এরর হ্যান্ডলিং (প্রোডাকশন)
; display_errors = Off
; error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

; OPcache
opcache.enable = 1
opcache.memory_consumption = 256
opcache.max_accelerated_files = 20000
opcache.validate_timestamps = 1  ; প্রোডাকশনে ০
opcache.jit = 1255
opcache.jit_buffer_size = 128M

; সেশন
session.save_handler = files
session.save_path = "/home/user/webstack/tmp/sessions"
session.gc_maxlifetime = 86400

; টাইমজোন
date.timezone = UTC

; নিরাপত্তা
expose_php = Off
```

</details>

### PHP-FPM পুল: `php/etc/php-fpm.conf`

<details>
<summary><strong>💻 Code Block (ini) — 18 lines</strong></summary>

```ini
[global]
pid = /path/to/php-fpm.pid
error_log = /path/to/php-fpm.log
daemonize = yes

[www]
listen = /path/to/php-fpm.sock
listen.mode = 0666

user = username
group = groupname

pm = dynamic
pm.max_children = 25
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
pm.max_requests = 500
```

</details>

## ৮.৩ MySQL কনফিগারেশন

### my.cnf: `mysql/my.cnf`

<details>
<summary><strong>💻 Code Block (ini) — 31 lines</strong></summary>

```ini
[mysqld]
basedir = /home/user/webstack/mysql
datadir = /home/user/webstack/data/mysql
socket = /home/user/webstack/tmp/mysql.sock
port = 3306
bind-address = 127.0.0.1

# ক্যারেক্টার সেট
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# সংযোগ
max_connections = 100
wait_timeout = 600

# InnoDB
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
innodb_file_per_table = 1

# কোয়েরি ক্যাশ
query_cache_type = 1
query_cache_size = 32M

# লগিং
slow_query_log = 1
long_query_time = 2

[client]
socket = /home/user/webstack/tmp/mysql.sock
default-character-set = utf8mb4
```

</details>

## ৮.৪ Redis কনফিগারেশন

### redis.conf: `redis/redis.conf`

<details>
<summary><strong>💻 Code Block (ini) — 23 lines</strong></summary>

```ini
# নেটওয়ার্ক
bind 127.0.0.1
port 6379
timeout 0

# সাধারণ
daemonize yes
pidfile /home/user/webstack/tmp/redis.pid
logfile /home/user/webstack/logs/redis.log

# পার্সিস্টেন্স
dir /home/user/webstack/data/redis
dbfilename dump.rdb
save 900 1
save 300 10
save 60 10000

# মেমরি
maxmemory 128mb
maxmemory-policy allkeys-lru

# নিরাপত্তা
# requirepass your_password
```

</details>

## ৮.৫ এনভায়রনমেন্ট ভেরিয়েবল

### এনভায়রনমেন্ট লোড করুন: `source scripts/env.sh`

<details>
<summary><strong>💻 Code Block (bash) — 4 lines</strong></summary>

```bash
export WEBSTACK_ROOT="$HOME/webstack"
export PATH="$WEBSTACK_ROOT/deps/bin:$WEBSTACK_ROOT/php/bin:$WEBSTACK_ROOT/node/bin:$WEBSTACK_ROOT/mysql/bin:$PATH"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/deps/lib:$LD_LIBRARY_PATH"
export SSL_CERT_FILE="$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem"
```

</details>

---

# ৯. ডেভেলপমেন্ট গাইড

## ৯.১ PHP ডেভেলপমেন্ট

### Laravel প্রজেক্ট

<details>
<summary><strong>💻 Code Block (bash) — 24 lines</strong></summary>

```bash
# প্রজেক্ট তৈরি করুন
cd ~/webstack/www
../composer create-project laravel/laravel myapp
cd myapp

# .env কনফিগার করুন
DB_CONNECTION=mysql
DB_HOST=localhost
DB_SOCKET=/home/user/webstack/tmp/mysql.sock
DB_DATABASE=myapp
DB_USERNAME=root
DB_PASSWORD=

CACHE_DRIVER=redis
SESSION_DRIVER=redis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

# ডাটাবেস তৈরি করুন
~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root \
    -e "CREATE DATABASE myapp"

# মাইগ্রেশন চালান
../../../php/bin/php artisan migrate
```

</details>

Nginx কনফিগ Laravel এর জন্য: সেকশন ৮.১ দেখুন

### WordPress

<details>
<summary><strong>💻 Code Block (bash) — 7 lines</strong></summary>

```bash
cd ~/webstack/www
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz && rm latest.tar.gz

# ডাটাবেস তৈরি করুন
~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root \
    -e "CREATE DATABASE wordpress"
```

</details>

`wp-config.php` কনফিগার করুন:
<details>
<summary><strong>💻 Code Block (php) — 4 lines</strong></summary>

```php
define('DB_NAME', 'wordpress');
define('DB_USER', 'root');
define('DB_PASSWORD', '');
define('DB_HOST', 'localhost:/home/user/webstack/tmp/mysql.sock');
```

</details>

### PHP তে Redis ব্যবহার করা

<details>
<summary><strong>💻 Code Block (php) — 22 lines</strong></summary>

```php
<?php
// সংযোগ করুন
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);

// ক্যাশিং উদাহরণ
function cache($key, $callback, $ttl = 3600) {
    global $redis;
    $data = $redis->get($key);
    if ($data === false) {
        $data = $callback();
        $redis->setex($key, $ttl, serialize($data));
        return $data;
    }
    return unserialize($data);
}

// ব্যবহার
$users = cache('users:all', function() {
    global $pdo;
    return $pdo->query('SELECT * FROM users')->fetchAll();
}, 300);
```

</details>

### PHP তে Memcached ব্যবহার করা

<details>
<summary><strong>💻 Code Block (php) — 7 lines</strong></summary>

```php
<?php
$mc = new Memcached();
$mc->addServer('127.0.0.1', 11211);

// সেশন ডাটা সংরক্ষণ করুন
$mc->set('session:abc123', ['user_id' => 1, 'name' => 'জন'], 3600);
$session = $mc->get('session:abc123');
```

</details>

## ৯.২ Node.js ডেভেলপমেন্ট

### Express API

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
cd ~/webstack/www
mkdir api && cd api

# ইনিশিয়ালাইজ করুন
~/webstack/node/bin/node ~/webstack/node/bin/npm init -y
~/webstack/node/bin/node ~/webstack/node/bin/npm install express cors
```

</details>

`app.js` তৈরি করুন:
<details>
<summary><strong>💻 Code Block (javascript) — 12 lines</strong></summary>

```javascript
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

app.get('/api/users', (req, res) => {
    res.json([{ id: 1, name: 'জন' }]);
});

app.listen(3000, '127.0.0.1');
```

</details>

### Socket.IO সহ WebSocket

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
cd ~/webstack/ws
~/webstack/node/bin/node ~/webstack/node/bin/npm install socket.io
```

</details>

## ৯.৩ ডাটাবেস ডেভেলপমেন্ট

### ডাটাবেস ও ব্যবহারকারী তৈরি করুন

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root << 'SQL'
CREATE DATABASE myapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON myapp.* TO 'myuser'@'localhost';
FLUSH PRIVILEGES;
SQL
```

</details>

### মাইগ্রেশন

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
# মাইগ্রেশন ডিরেক্টরি তৈরি করুন
mkdir -p ~/webstack/www/myapp/migrations

# মাইগ্রেশন চালান
~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root myapp \
    < migrations/001_create_users.sql
```

</details>

---

# ১০. প্রোডাকশন ডিপ্লয়মেন্ট

## ১০.১ ডিপ্লয়মেন্ট-পূর্ব চেকলিস্ট

- [ ] সাইজ কমাতে `./cleanup.sh` চালান
- [ ] PHP `display_errors` অক্ষম করুন
- [ ] `validate_timestamps=0` সহ OPcache সক্রিয় করুন
- [ ] সঠিক SSL সার্টিফিকেট কনফিগার করুন (Let's Encrypt)
- [ ] শক্তিশালী MySQL root পাসওয়ার্ড সেট করুন
- [ ] phpMyAdmin সরান বা সীমাবদ্ধ করুন
- [ ] ফায়ারওয়াল নিয়ম কনফিগার করুন
- [ ] স্বয়ংক্রিয় ব্যাকআপ সেটআপ করুন
- [ ] লগ রোটেশন কনফিগার করুন
- [ ] Redis পাসওয়ার্ড সেট করুন

## ১০.২ প্রোডাকশন সেটিংস

### PHP (php.ini)

<details>
<summary><strong>💻 Code Block (ini) — 7 lines</strong></summary>

```ini
display_errors = Off
log_errors = On
opcache.validate_timestamps = 0
opcache.memory_consumption = 256
expose_php = Off
session.cookie_secure = 1
session.cookie_httponly = 1
```

</details>

### Nginx নিরাপত্তা হেডার

<details>
<summary><strong>💻 Code Block (nginx) — 4 lines</strong></summary>

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Strict-Transport-Security "max-age=31536000" always;
```

</details>

### Redis

<details>
<summary><strong>💻 Code Block (ini) — 2 lines</strong></summary>

```ini
# redis.conf
requirepass your_strong_password_here
```

</details>

## ১০.৩ Let's Encrypt সহ SSL

<details>
<summary><strong>💻 Code Block (bash) — 13 lines</strong></summary>

```bash
# certbot ইনস্টল করুন
sudo apt install certbot

# সার্টিফিকেট পান
sudo certbot certonly --standalone -d yourdomain.com

# WebStack এ কপি করুন
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ~/webstack/nginx/conf/ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ~/webstack/nginx/conf/ssl/key.pem
sudo chown $(whoami) ~/webstack/nginx/conf/ssl/*.pem

# রিস্টার্ট করুন
./webstack restart
```

</details>

## ১০.৪ Systemd সার্ভিস

`/etc/systemd/system/webstack.service` তৈরি করুন:

<details>
<summary><strong>💻 Code Block (ini) — 14 lines</strong></summary>

```ini
[Unit]
Description=WebStack Web Server
After=network.target

[Service]
Type=forking
User=webuser
WorkingDirectory=/home/webuser/webstack
ExecStart=/home/webuser/webstack/webstack start
ExecStop=/home/webuser/webstack/webstack stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

</details>

<details>
<summary><strong>💻 Code Block (bash) — 3 lines</strong></summary>

```bash
sudo systemctl daemon-reload
sudo systemctl enable webstack
sudo systemctl start webstack
```

</details>

---

# ১১. ব্যাকআপ ও রিকভারি

## ১১.১ ম্যানুয়াল ব্যাকআপ

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./scripts/backup.sh
```

</details>

`backups/` এ তৈরি করে:
- `www_TIMESTAMP.tar.gz` - ওয়েব ফাইল
- `mysql_TIMESTAMP.sql.gz` - ডাটাবেস
- `config_TIMESTAMP.tar.gz` - কনফিগারেশন

## ১১.২ স্বয়ংক্রিয় ব্যাকআপ (Cron)

<details>
<summary><strong>💻 Code Block (bash) — 7 lines</strong></summary>

```bash
crontab -e

# প্রতিদিন রাত ২টায়
0 2 * * * /home/user/webstack/scripts/backup.sh

# সাপ্তাহিক ক্লিনআপ
0 3 * * 0 find /home/user/webstack/backups -mtime +30 -delete
```

</details>

## ১১.৩ রিস্টোর করা

<details>
<summary><strong>💻 Code Block (bash) — 11 lines</strong></summary>

```bash
# ওয়েব ফাইল রিস্টোর করুন
cd ~/webstack
tar -xzf backups/www_20240227_020000.tar.gz

# ডাটাবেস রিস্টোর করুন
gunzip -c backups/mysql_20240227_020000.sql.gz | \
    ./mysql/bin/mysql --socket=./tmp/mysql.sock -u root

# কনফিগ রিস্টোর করুন
tar -xzf backups/config_20240227_020000.tar.gz
./webstack restart
```

</details>

---

# ১২. সমস্যা সমাধান

## ১২.১ সাধারণ সমস্যা

### সার্ভিস শুরু হচ্ছে না

<details>
<summary><strong>💻 Code Block (bash) — 13 lines</strong></summary>

```bash
# কী সমস্যা তা চেক করুন
./webstack status

# নির্দিষ্ট সার্ভিস চেক করুন
./php/sbin/php-fpm -t
./nginx/sbin/nginx -t -p ~/webstack/nginx

# অনুপস্থিত লাইব্রেরি চেক করুন
ldd ./nginx/sbin/nginx | grep "not found"
ldd ./php/sbin/php-fpm | grep "not found"

# লাইব্রেরি পাথ ঠিক করুন
export LD_LIBRARY_PATH="$HOME/webstack/deps/lib:$LD_LIBRARY_PATH"
```

</details>

### পোর্ট ৮০/৪৪৩ পারমিশন অস্বীকৃত

<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
# অপশন ১: setcap ব্যবহার করুন
sudo setcap 'cap_net_bind_service=+ep' ~/webstack/nginx/sbin/nginx

# অপশন ২: > ১০২৪ পোর্ট ব্যবহার করুন
# nginx.conf সম্পাদনা করুন: listen 8080;
```

</details>

### Redis/Memcached সনাক্ত হচ্ছে না

<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# ইনস্টলেশন পাথ চেক করুন
ls -la ~/webstack/deps/bin/redis-server
ls -la ~/webstack/deps/bin/memcached

# PHP এক্সটেনশন চেক করুন
./php/bin/php -m | grep -E "(redis|memcached)"

# এক্সটেনশন পরিবর্তনের পর PHP-FPM রিস্টার্ট করুন
kill -USR2 $(cat php/var/run/php-fpm.pid)
```

</details>

### MySQL সংযোগ সমস্যা

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# সকেট আছে কিনা চেক করুন
ls -la ~/webstack/tmp/mysql.sock

# MySQL চলছে কিনা চেক করুন
./webstack status

# সংযোগ টেস্ট করুন
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root -e "SELECT 1"
```

</details>

## ১২.২ লগ চেক করা

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# সব লগ
./webstack logs

# নির্দিষ্ট সার্ভিস
./scripts/logs.sh nginx
./scripts/logs.sh php
./scripts/logs.sh mysql
./scripts/logs.sh redis
./scripts/logs.sh cloudflare

# নির্দিষ্ট লগ টেইল করুন
tail -f nginx/logs/error.log
tail -f php/var/log/php-fpm.log
tail -f logs/redis.log
```

</details>

## ১২.৩ সার্ভিস রিসেট করা

<details>
<summary><strong>💻 Code Block (bash) — 11 lines</strong></summary>

```bash
# সবকিছু বন্ধ করুন
./webstack stop

# রানটাইম ফাইল মুছুন
rm -f tmp/*.pid tmp/*.sock

# কনফিগ পুনরায় তৈরি করুন
./setup.sh

# নতুন করে শুরু করুন
./webstack start
```

</details>

---

# ১৩. নিরাপত্তা

## ১৩.১ নিরাপত্তা চেকলিস্ট

- [ ] MySQL root পাসওয়ার্ড সেট করুন
- [ ] Redis পাসওয়ার্ড সেট করুন
- [ ] phpMyAdmin অ্যাক্সেস সীমাবদ্ধ করুন
- [ ] HTTPS সক্রিয় করুন
- [ ] ফায়ারওয়াল কনফিগার করুন
- [ ] অপ্রয়োজনীয় PHP ফাংশন অক্ষম করুন
- [ ] উপাদান আপডেট রাখুন

## ১৩.২ MySQL নিরাপত্তা

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root << 'SQL'
ALTER USER 'root'@'localhost' IDENTIFIED BY 'strong_password';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
SQL
```

</details>

## ১৩.৩ Redis নিরাপত্তা

`redis/redis.conf` সম্পাদনা করুন:
<details>
<summary><strong>💻 Code Block (ini) — 1 lines</strong></summary>

```ini
requirepass your_strong_password
```

</details>

PHP কোড আপডেট করুন:
<details>
<summary><strong>💻 Code Block (php) — 3 lines</strong></summary>

```php
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);
$redis->auth('your_strong_password');
```

</details>

## ১৩.৪ Nginx নিরাপত্তা

<details>
<summary><strong>💻 Code Block (nginx) — 13 lines</strong></summary>

```nginx
# সংস্করণ লুকান
server_tokens off;

# নিরাপত্তা হেডার
add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options "nosniff";
add_header X-XSS-Protection "1; mode=block";

# phpMyAdmin সীমাবদ্ধ করুন
location /phpmyadmin {
    allow 192.168.1.0/24;
    deny all;
}
```

</details>

## ১৩.৫ PHP নিরাপত্তা

<details>
<summary><strong>💻 Code Block (ini) — 6 lines</strong></summary>

```ini
; php.ini
expose_php = Off
display_errors = Off
disable_functions = exec,passthru,shell_exec,system,proc_open,popen
session.cookie_httponly = 1
session.cookie_secure = 1
```

</details>

---

# ১৪. পারফরম্যান্স টিউনিং

## ১৪.১ Nginx

<details>
<summary><strong>💻 Code Block (nginx) — 17 lines</strong></summary>

```nginx
worker_processes auto;
worker_connections 4096;

# বাফার
client_body_buffer_size 128k;
proxy_buffer_size 128k;

# Gzip
gzip on;
gzip_comp_level 6;
gzip_types text/plain text/css application/json application/javascript;

# স্ট্যাটিক ফাইল
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

</details>

## ১৪.২ PHP

<details>
<summary><strong>💻 Code Block (ini) — 14 lines</strong></summary>

```ini
; OPcache
opcache.enable = 1
opcache.memory_consumption = 256
opcache.max_accelerated_files = 20000
opcache.validate_timestamps = 0
opcache.jit = 1255
opcache.jit_buffer_size = 128M

; PHP-FPM
pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
```

</details>

## ১৪.৩ MySQL

<details>
<summary><strong>💻 Code Block (ini) — 4 lines</strong></summary>

```ini
innodb_buffer_pool_size = 1G  ; ডেডিকেটেড সার্ভারে RAM এর ৭০-৮০%
innodb_log_file_size = 256M
query_cache_size = 64M
thread_cache_size = 50
```

</details>

## ১৪.৪ Redis

<details>
<summary><strong>💻 Code Block (ini) — 2 lines</strong></summary>

```ini
maxmemory 256mb
maxmemory-policy allkeys-lru
```

</details>

---

# ১৫. API রেফারেন্স

## ১৫.১ Node.js API এন্ডপয়েন্ট

| মেথড | এন্ডপয়েন্ট | বর্ণনা |
|------|------------|--------|
| GET | `/api/status` | সার্ভার স্ট্যাটাস |
| GET | `/api/health` | হেলথ চেক |
| POST | `/api/echo` | ইকো রিকোয়েস্ট |
| GET | `/api/events` | SSE স্ট্রিম |

### রেসপন্স উদাহরণ

**GET /api/status**
<details>
<summary><strong>💻 Code Block (json) — 8 lines</strong></summary>

```json
{
    "status": "ok",
    "service": "WebStack Node.js API",
    "node": "v20.10.0",
    "uptime": 3600,
    "memory": "45 MB",
    "time": "2024-02-27T12:00:00.000Z"
}
```

</details>

## ১৫.২ WebSocket মেসেজ

**সার্ভার → ক্লায়েন্ট:**
<details>
<summary><strong>💻 Code Block (json) — 5 lines</strong></summary>

```json
{"type": "welcome", "id": 1, "clients": 5}
{"type": "echo", "data": "আপনার বার্তা"}
{"type": "broadcast", "from": 2, "data": "বার্তা"}
{"type": "client_joined", "id": 3, "clients": 6}
{"type": "client_left", "id": 2, "clients": 5}
```

</details>

## ১৫.৩ RTMP পরিসংখ্যান

nginx.conf এ সক্রিয় করুন:
<details>
<summary><strong>💻 Code Block (nginx) — 3 lines</strong></summary>

```nginx
location /rtmp_stat {
    rtmp_stat all;
}
```

</details>

অ্যাক্সেস: `http://localhost/rtmp_stat`

---

# ১৬. উদাহরণসমূহ

## ১৬.১ PHP + Redis সেশন

<details>
<summary><strong>💻 Code Block (php) — 27 lines</strong></summary>

```php
<?php
session_set_save_handler(new RedisSessionHandler());
session_start();

class RedisSessionHandler implements SessionHandlerInterface {
    private $redis;
    private $ttl = 3600;
    
    public function open($path, $name): bool {
        $this->redis = new Redis();
        return $this->redis->connect('127.0.0.1', 6379);
    }
    
    public function read($id): string {
        return $this->redis->get("session:$id") ?: '';
    }
    
    public function write($id, $data): bool {
        return $this->redis->setex("session:$id", $this->ttl, $data);
    }
    
    public function destroy($id): bool {
        return $this->redis->del("session:$id") > 0;
    }
    
    // ... অন্যান্য মেথড ইমপ্লিমেন্ট করুন
}
```

</details>

## ১৬.২ রিয়েল-টাইম চ্যাট

`ws/server.js` দেখুন এবং WebSocket সংযোগ সহ ক্লায়েন্ট HTML তৈরি করুন।

## ১৬.৩ লাইভ স্ট্রিমিং সেটআপ

১. OBS কনফিগার করুন → `rtmp://localhost:1935/live/mystream`
২. HLS.js সহ প্লেয়ার পেজ তৈরি করুন
৩. `http://localhost/hls/mystream.m3u8` এ অ্যাক্সেস করুন

---

# ১৭. সাধারণ প্রশ্নোত্তর

**প্র: আমি কি Windows এ চালাতে পারি?**
উ: WSL2 (Windows Subsystem for Linux) ব্যবহার করুন।

**প্র: রুট অ্যাক্সেস দরকার কি?**
উ: শুধুমাত্র পোর্ট ৮০/৪৪৩ এর জন্য। `setcap` বা উচ্চতর পোর্ট ব্যবহার করুন।

**প্র: উপাদান কীভাবে আপডেট করব?**
উ: নতুন সংস্করণ সহ সোর্স থেকে পুনরায় বিল্ড করুন।

**প্র: পরিবর্তে Docker ব্যবহার করতে পারি?**
উ: ওয়েবস্ট্যাক Docker এর চেয়ে হালকা হওয়ার জন্য ডিজাইন করা হয়েছে অনুরূপ বিচ্ছিন্নতা প্রদান করে।

**প্র: Redis এ SSL কীভাবে যোগ করব?**
উ: stunnel ব্যবহার করুন বা TLS সহ Redis (পুনঃকম্পাইলেশন প্রয়োজন)।

**প্র: একাধিক ইনস্ট্যান্স চালাতে পারি?**
উ: হ্যাঁ, ভিন্ন পোর্ট এবং পাথ ব্যবহার করুন।

**প্র: প্রোডাকশনে কীভাবে মাইগ্রেট করব?**
উ: `./package.sh` চালান, সার্ভারে কপি করুন, `./INSTALL.sh` চালান।

---

# ১৮. পরিশিষ্ট

## ১৮.১ পোর্ট রেফারেন্স

| পোর্ট | সার্ভিস | প্রোটোকল |
|-------|---------|----------|
| ৮০ | HTTP | TCP |
| ৪৪৩ | HTTPS/HTTP3 | TCP/UDP |
| ১৯৩৫ | RTMP | TCP |
| ১৯৩৬ | RTMPS | TCP |
| ৩০০০ | Node.js API | TCP |
| ৩৩০৬ | MySQL | TCP |
| ৬৩৭৯ | Redis | TCP |
| ৮০৮১ | WebSocket | TCP |
| ১১২১১ | Memcached | TCP |

## ১৮.২ দ্রুত কমান্ড চিটশিট

<details>
<summary><strong>💻 Code Block (bash) — 25 lines</strong></summary>

```bash
# সার্ভিস
./webstack start|stop|restart|status

# টানেল
./webstack tunnel daemon
./webstack tunnel url

# ক্যাশ
./webstack cache status
./webstack cache flush
./webstack redis cli PING
./webstack memcached stats

# লগ
./webstack logs

# PHP
./php/bin/php -v
./php/bin/php -m

# MySQL
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root

# ব্যাকআপ
./scripts/backup.sh
```

</details>

## ১৮.৩ ফাইল অবস্থান

| কী | কোথায় |
|----|--------|
| ওয়েব রুট | `www/` |
| Nginx কনফিগ | `nginx/conf/nginx.conf` |
| PHP কনফিগ | `php/etc/php.ini` |
| MySQL কনফিগ | `mysql/my.cnf` |
| Redis কনফিগ | `redis/redis.conf` |
| লগ | `logs/`, `nginx/logs/`, `php/var/log/` |
| ব্যাকআপ | `backups/` |
| CA সার্টিফিকেট | `deps/ssl/certs/cacert.pem` |

---

**ওয়েবস্ট্যাক পোর্টেবল ওয়েব সার্ভার সংস্করণ ২.০**

*Nginx, PHP ৮.৩, Node.js, MySQL, Redis, Memcached, RTMP স্ট্রিমিং, এবং Cloudflare টানেল সমর্থন সহ একটি সম্পূর্ণ স্বয়ংসম্পূর্ণ ওয়েব ডেভেলপমেন্ট পরিবেশ।*

---

# দ্রুত শুরু সারাংশ (বাংলা)

## ইনস্টলেশন

<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# প্যাকেজ এক্সট্র্যাক্ট করুন
tar -xzf webstack_portable.tar.gz
cd webstack

# ইনস্টল করুন
./INSTALL.sh

# শুরু করুন
./webstack start
```

</details>

## প্রতিদিনের কমান্ড

| কাজ | কমান্ড |
|-----|--------|
| সব শুরু করুন | `./webstack start` |
| সব বন্ধ করুন | `./webstack stop` |
| স্ট্যাটাস দেখুন | `./webstack status` |
| পাবলিক URL পান | `./webstack tunnel daemon` |
| URL দেখুন | `./webstack tunnel url` |
| ক্যাশ ফ্লাশ করুন | `./webstack cache flush` |
| লগ দেখুন | `./webstack logs` |
| ব্যাকআপ নিন | `./scripts/backup.sh` |

## গুরুত্বপূর্ণ URL

| সার্ভিস | URL |
|---------|-----|
| ওয়েবসাইট | http://localhost |
| HTTPS | https://localhost |
| phpMyAdmin | http://localhost/phpmyadmin |
| PHP তথ্য | http://localhost/phpinfo.php |
| ক্যাশ টেস্ট | http://localhost/test_cache.php |
| API | http://localhost/api/status |
| RTMP | rtmp://localhost:1935/live/streamkey |

## সংযোগ তথ্য

| সার্ভিস | সংযোগ |
|---------|--------|
| MySQL | socket: `tmp/mysql.sock` |
| Redis | `127.0.0.1:6379` |
| Memcached | `127.0.0.1:11211` |
| PHP-FPM | socket: `tmp/php-fpm.sock` |

---

**© ২০২৪ ওয়েবস্ট্যাক - সম্পূর্ণ পোর্টেবল ওয়েব সার্ভার**

---

# Table of Contents

1. [Introduction](#1-introduction)
2. [System Requirements](#2-system-requirements)
3. [Installation](#3-installation)
4. [Directory Structure](#4-directory-structure)
5. [Quick Start](#5-quick-start)
6. [Command Reference](#6-command-reference)
7. [Components](#7-components)
   - [Nginx](#71-nginx)
   - [PHP](#72-php)
   - [Node.js](#73-nodejs)
   - [MySQL/MariaDB](#74-mysqlmariadb)
   - [Redis](#75-redis)
   - [Memcached](#76-memcached)
   - [WebSocket](#77-websocket)
   - [RTMP Streaming](#78-rtmp-streaming)
   - [Cloudflare Tunnel](#79-cloudflare-tunnel)
   - [FFmpeg](#710-ffmpeg)
   - [Composer](#711-composer)
8. [Configuration](#8-configuration)
9. [Development Guide](#9-development-guide)
10. [Production Deployment](#10-production-deployment)
11. [Backup & Recovery](#11-backup--recovery)
12. [Troubleshooting](#12-troubleshooting)
13. [Security](#13-security)
14. [Performance Tuning](#14-performance-tuning)
15. [API Reference](#15-api-reference)
16. [Examples](#16-examples)
17. [FAQ](#17-faq)
18. [Appendix](#18-appendix)

---

# 1. Introduction

## 1.1 What is WebStack?

WebStack is a **fully portable, self-contained web server environment** that runs entirely from a single directory without requiring root privileges or system-wide installation. It provides everything needed to develop and deploy modern web applications.

### Core Components

| Component | Version | Description |
|-----------|---------|-------------|
| **Nginx** | 1.25.4 | Web server with HTTP/2, HTTP/3, RTMP |
| **PHP** | 8.3.2 | PHP-FPM with 50+ extensions |
| **Node.js** | 20.10.0 | JavaScript runtime with npm |
| **MySQL** | MariaDB 11.2 | Database server |
| **Redis** | 7.2.4 | In-memory data store |
| **Memcached** | 1.6.23 | High-performance caching |
| **FFmpeg** | Latest | Media processing |
| **Cloudflared** | Latest | Tunnel for public access |

## 1.2 Key Features

| Feature | Description |
|---------|-------------|
| **100% Portable** | Entire stack runs from `~/webstack` - copy anywhere |
| **No Root Required** | Runs as regular user (except ports 80/443) |
| **Self-Contained** | All dependencies built-in, no system libraries needed |
| **HTTP/3 Ready** | QUIC protocol support for faster connections |
| **Live Streaming** | RTMP/RTMPS ingest with HLS output |
| **Instant Public URL** | Cloudflare tunnel with auto-reconnect |
| **Modern Caching** | Redis and Memcached with PHP extensions |
| **Real-time** | WebSocket and Server-Sent Events support |
| **PHP 8.3** | Latest PHP with JIT, OPcache, all extensions |

## 1.3 Architecture Overview

<details>
<summary><strong>💻 Code Block — 33 lines</strong></summary>

```
┌─────────────────────────────────────────────────────────────────────┐
│                            INTERNET                                  │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │    Cloudflare Tunnel      │
                    │  (Random Public HTTPS)    │
                    └─────────────┬─────────────┘
                                  │
┌─────────────────────────────────┴───────────────────────────────────┐
│                            NGINX                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │ HTTP:80  │  │HTTPS:443 │  │RTMP:1935 │  │RTMPS:1936│            │
│  │  HTTP/2  │  │  HTTP/3  │  │   Live   │  │  Secure  │            │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘            │
└───────┼─────────────┼─────────────┼─────────────┼───────────────────┘
        │             │             │             │
   ┌────┴────┐   ┌────┴────┐   ┌────┴────┐       │
   ▼         ▼   ▼         ▼   ▼         │       │
┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐   │       │
│ PHP  │  │Node  │  │  WS  │  │ HLS  │◄──┘       │
│ FPM  │  │ .js  │  │Server│  │Output│           │
└──┬───┘  └──┬───┘  └──────┘  └──────┘           │
   │         │                                    │
   └────┬────┘                                    │
        │                                         │
   ┌────┴────────────────────────────────────────┐
   │              DATA LAYER                      │
   │  ┌────────┐  ┌────────┐  ┌───────────┐     │
   │  │ MySQL  │  │ Redis  │  │ Memcached │     │
   │  │MariaDB │  │ :6379  │  │  :11211   │     │
   │  └────────┘  └────────┘  └───────────┘     │
   └──────────────────────────────────────────────┘
```

</details>

## 1.4 Use Cases

- **Local Development** - Full LAMP/LEMP stack without Docker or VMs
- **Testing** - Isolated environment for testing applications
- **Education** - Learning web development and server administration
- **Portable Projects** - Carry your entire dev environment on USB
- **Live Streaming** - Personal streaming server with RTMP/HLS
- **Demo/Presentation** - Quick public access via Cloudflare tunnel
- **Microservices** - Node.js API with PHP backend
- **Caching Layer** - Redis/Memcached for session and data caching

---

# 2. System Requirements

## 2.1 Minimum Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **OS** | Linux 64-bit | Ubuntu 22.04+, Debian 12+ |
| **CPU** | 2 cores | 4+ cores |
| **RAM** | 2 GB | 4+ GB |
| **Disk** | 5 GB | 10+ GB |
| **Architecture** | x86_64, ARM64 | x86_64 |

## 2.2 Supported Operating Systems

| OS | Status | Notes |
|----|--------|-------|
| Ubuntu 20.04+ | ✅ Fully Supported | Recommended |
| Debian 10+ | ✅ Fully Supported | |
| Linux Mint 20+ | ✅ Fully Supported | |
| CentOS 7/8/Stream | ✅ Supported | |
| Rocky Linux 8/9 | ✅ Supported | |
| AlmaLinux 8/9 | ✅ Supported | |
| Fedora 36+ | ✅ Supported | |
| Arch Linux | ✅ Supported | |
| WSL2 | ✅ Supported | Windows 10/11 |
| macOS | ⚠️ Partial | Requires modifications |

## 2.3 Build Dependencies

Install these before building from source:

### Ubuntu/Debian

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
sudo apt update
sudo apt install -y \
    build-essential autoconf libtool pkg-config \
    git wget curl cmake ninja-build \
    libsqlite3-dev libreadline-dev libbz2-dev libgmp-dev \
    libxml2-dev libssl-dev libcurl4-openssl-dev \
    libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev \
    libonig-dev libzip-dev libsodium-dev libicu-dev
```

</details>

### CentOS/RHEL/Rocky/Alma

<details>
<summary><strong>💻 Code Block (bash) — 7 lines</strong></summary>

```bash
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y \
    autoconf libtool pkgconfig git wget curl cmake \
    sqlite-devel readline-devel bzip2-devel gmp-devel \
    libxml2-devel openssl-devel libcurl-devel \
    libpng-devel libjpeg-devel libwebp-devel freetype-devel \
    oniguruma-devel libzip-devel libsodium-devel libicu-devel
```

</details>

### Arch Linux

<details>
<summary><strong>💻 Code Block (bash) — 4 lines</strong></summary>

```bash
sudo pacman -S base-devel git wget curl cmake ninja \
    sqlite readline bzip2 gmp libxml2 openssl curl \
    libpng libjpeg-turbo libwebp freetype2 \
    oniguruma libzip libsodium icu
```

</details>

---

# 3. Installation

## 3.1 Quick Install (Pre-built Package)

If you have a pre-built WebStack package:

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# 1. Extract package
tar -xzf webstack_portable_YYYYMMDD.tar.gz

# 2. Enter directory
cd webstack

# 3. Run installer
./INSTALL.sh

# 4. Start all services
./webstack start

# 5. Open browser
xdg-open http://localhost
```

</details>

## 3.2 Build from Source (Complete)

### Step 1: Prepare Environment

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
# Create base directory
mkdir -p ~/webstack
cd ~/webstack

# Create directory structure
./setup_directories.sh
```

</details>

### Step 2: Build Nginx Dependencies

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./build_nginx_deps.sh
```

</details>

**Builds:** PCRE2, zlib, OpenSSL (with QUIC), libatomic_ops, libmaxminddb, libxml2, libxslt

**Duration:** ~10-15 minutes

### Step 3: Build Nginx

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./build_nginx.sh
```

</details>

**Features:** HTTP/2, HTTP/3, RTMP, Push Stream, Brotli, GeoIP2, NJS

**Duration:** ~10-15 minutes

### Step 4: Build PHP Dependencies

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./build_php_deps.sh
```

</details>

**Builds:** All image libraries, encryption libraries, ICU, curl, hiredis, libmemcached

**Duration:** ~20-30 minutes

### Step 5: Build PHP

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./build_php.sh
```

</details>

**Features:** PHP 8.3 with FPM, JIT, OPcache, 50+ extensions including Redis and Memcached

**Duration:** ~15-25 minutes

### Step 6: Install Node.js

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./install_node.sh
```

</details>

**Duration:** ~1 minute

### Step 7: Install Optional Components

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# MySQL/MariaDB database
./setup_mysql.sh

# Redis & Memcached (servers + PHP extensions)
./install_redis_memcached.sh

# Composer (PHP package manager)
./setup_composer.sh

# FFmpeg (media processing)
./install_ffmpeg.sh

# Cloudflare Tunnel
./install_cloudflared.sh
```

</details>

### Step 8: Generate Configuration

<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
# Generate all config files
./setup.sh

# Create management scripts
./create_scripts.sh
```

</details>

### Step 9: Start Services

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./webstack start
```

</details>

## 3.3 Verify Installation

<details>
<summary><strong>💻 Code Block (bash) — 20 lines</strong></summary>

```bash
# Check all services
./webstack status

# Test HTTP
curl http://localhost

# Test PHP
curl http://localhost/index.php

# Test cache
curl http://localhost/test_cache.php

# Test API
curl http://localhost/api/status

# Component versions
./php/bin/php -v
./node/bin/node -v
./nginx/sbin/nginx -v
./deps/bin/redis-server --version
```

</details>

## 3.4 Build Scripts Reference

| Script | Purpose | Duration |
|--------|---------|----------|
| `setup_directories.sh` | Create directory structure | <1 min |
| `build_nginx_deps.sh` | Build Nginx dependencies | 10-15 min |
| `build_nginx.sh` | Build Nginx server | 10-15 min |
| `build_php_deps.sh` | Build PHP dependencies | 20-30 min |
| `build_php.sh` | Build PHP with extensions | 15-25 min |
| `install_node.sh` | Install Node.js | <1 min |
| `setup_mysql.sh` | Install MariaDB | 2-3 min |
| `install_redis_memcached.sh` | Install Redis & Memcached | 5-10 min |
| `setup_composer.sh` | Install Composer | <1 min |
| `install_ffmpeg.sh` | Install FFmpeg | <1 min |
| `install_cloudflared.sh` | Install Cloudflare CLI | <1 min |
| `setup.sh` | Generate configurations | <1 min |
| `create_scripts.sh` | Create management scripts | <1 min |

---

# 4. Directory Structure

<details>
<summary><strong>💻 Code Block — 172 lines</strong></summary>

```
~/webstack/
│
├── webstack                 # Main control script ⭐
├── composer                 # Composer wrapper script
├── setup.sh                 # Configuration generator
├── create_scripts.sh        # Script generator
├── INSTALL.sh              # Quick installer
├── cleanup.sh              # Cleanup script
├── package.sh              # Packaging script
│
├── nginx/                   # Nginx Web Server
│   ├── sbin/
│   │   └── nginx           # Nginx binary
│   ├── conf/
│   │   ├── nginx.conf      # Main configuration ⭐
│   │   ├── mime.types      # MIME types
│   │   ├── fastcgi_params  # FastCGI parameters
│   │   ├── conf.d/         # Additional configs
│   │   │   └── *.conf      # Virtual hosts
│   │   └── ssl/
│   │       ├── cert.pem    # SSL certificate
│   │       └── key.pem     # SSL private key
│   ├── logs/
│   │   ├── access.log      # Access log
│   │   └── error.log       # Error log
│   └── modules/            # Dynamic modules
│
├── php/                     # PHP Installation
│   ├── bin/
│   │   ├── php             # PHP CLI
│   │   ├── phpize          # Extension builder
│   │   ├── php-config      # Configuration info
│   │   └── composer        # Composer binary
│   ├── sbin/
│   │   └── php-fpm         # PHP-FPM binary
│   ├── lib/
│   │   └── php/
│   │       └── extensions/ # Extension .so files
│   ├── etc/
│   │   ├── php.ini         # PHP configuration ⭐
│   │   ├── php-fpm.conf    # FPM configuration ⭐
│   │   ├── php-fpm.d/
│   │   │   └── www.conf    # Pool configuration
│   │   └── conf.d/         # Extension configs
│   │       ├── custom.ini
│   │       ├── ssl.ini
│   │       ├── redis.ini
│   │       └── memcached.ini
│   └── var/
│       ├── run/
│       │   └── php-fpm.pid
│       └── log/
│           ├── php-fpm.log
│           └── php-error.log
│
├── node/                    # Node.js Installation
│   ├── bin/
│   │   ├── node            # Node.js binary
│   │   ├── npm             # npm package manager
│   │   └── npx             # npm executor
│   └── lib/
│       └── node_modules/   # Global modules
│
├── mysql/                   # MariaDB Installation
│   ├── bin/
│   │   ├── mysql           # MySQL client
│   │   ├── mysqld          # MySQL server
│   │   ├── mysqldump       # Backup tool
│   │   └── mysqladmin      # Admin tool
│   ├── lib/                # MySQL libraries
│   └── my.cnf              # MySQL configuration ⭐
│
├── redis/                   # Redis Configuration
│   └── redis.conf          # Redis configuration ⭐
│
├── memcached/              # Memcached Configuration
│   └── memcached.conf      # Memcached reference
│
├── deps/                    # Shared Dependencies
│   ├── bin/
│   │   ├── openssl         # OpenSSL binary
│   │   ├── redis-server    # Redis server ⭐
│   │   ├── redis-cli       # Redis CLI ⭐
│   │   ├── memcached       # Memcached server ⭐
│   │   ├── ffmpeg          # FFmpeg binary
│   │   ├── ffprobe         # FFprobe binary
│   │   └── cloudflared     # Cloudflare tunnel
│   ├── lib/                # Shared libraries (.so)
│   │   ├── libssl.so*
│   │   ├── libcrypto.so*
│   │   ├── libz.so*
│   │   ├── libcurl.so*
│   │   ├── libhiredis.so*
│   │   ├── libmemcached.so*
│   │   └── ...
│   └── ssl/
│       └── certs/
│           └── cacert.pem  # CA certificates
│
├── www/                     # Web Root Directory ⭐
│   ├── index.html          # Default HTML page
│   ├── index.php           # PHP test page
│   ├── phpinfo.php         # PHP info page
│   ├── test_cache.php      # Cache test page ⭐
│   ├── app.js              # Node.js API server
│   ├── phpmyadmin/         # phpMyAdmin
│   ├── hls/                # HLS stream output
│   ├── videos/             # VOD videos
│   └── recordings/         # RTMP recordings
│
├── ws/                      # WebSocket Server
│   ├── server.js           # WebSocket server script
│   ├── package.json        # npm dependencies
│   └── node_modules/       # Installed modules
│
├── data/                    # Persistent Data
│   ├── mysql/              # MySQL data files
│   └── redis/              # Redis persistence
│
├── tmp/                     # Runtime Files
│   ├── nginx.pid
│   ├── php-fpm.sock
│   ├── mysql.sock
│   ├── mysql.pid
│   ├── redis.pid
│   ├── memcached.pid
│   ├── node.pid
│   ├── ws.pid
│   ├── cloudflare_tunnel.pid
│   ├── cloudflare_monitor.pid
│   ├── cloudflare_url.txt  # Current tunnel URL
│   ├── sessions/           # PHP sessions
│   ├── uploads/            # Temporary uploads
│   ├── client_body/        # Nginx client body
│   ├── proxy/              # Nginx proxy cache
│   └── fastcgi/            # Nginx FastCGI cache
│
├── logs/                    # Log Files
│   ├── node.log
│   ├── ws.log
│   ├── redis.log
│   ├── memcached.log
│   ├── mysql-error.log
│   └── cloudflare/
│       ├── tunnel.log
│       ├── cloudflared.log
│       └── url_history.log # All tunnel URLs ⭐
│
├── backups/                 # Backup Files
│   ├── www_TIMESTAMP.tar.gz
│   ├── mysql_TIMESTAMP.sql.gz
│   └── config_TIMESTAMP.tar.gz
│
├── scripts/                 # Management Scripts
│   ├── cloudflare_tunnel.sh
│   ├── start_redis.sh
│   ├── stop_redis.sh
│   ├── start_memcached.sh
│   ├── stop_memcached.sh
│   ├── start_mysql.sh
│   ├── stop_mysql.sh
│   ├── backup.sh
│   ├── renew_ssl.sh
│   ├── env.sh
│   ├── health.sh
│   └── logs.sh
│
└── src/                     # Source Files (removable)
    ├── nginx-1.25.4/
    ├── php-8.3.2/
    ├── redis-7.2.4/
    └── ...
```

</details>

---

# 5. Quick Start

## 5.1 Start Everything

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
cd ~/webstack
./webstack start
```

</details>

**Output:**
<details>
<summary><strong>💻 Code Block — 9 lines</strong></summary>

```
Starting Redis... OK
Starting Memcached... OK
Starting PHP-FPM... OK
Starting Nginx... OK
Starting Node.js... OK
Starting WebSocket... OK
Starting MySQL... OK

WebStack started!
```

</details>

## 5.2 Check Status

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./webstack status
```

</details>

**Output:**
<details>
<summary><strong>💻 Code Block — 35 lines</strong></summary>

```
========================================
WebStack Status
========================================

Core Services:
  Nginx:       RUNNING (PID: 12345)
  PHP-FPM:     RUNNING (PID: 12346)
  Node.js:     RUNNING (PID: 12347)
  WebSocket:   RUNNING (PID: 12348)

Database:
  MySQL:       RUNNING (socket)

Cache Services:
  Redis:       RUNNING (port: 6379, v7.2.4)
  Memcached:   RUNNING (port: 11211)

PHP Cache Extensions:
  redis:       LOADED
  memcached:   LOADED

External Access:
  Cloudflare:  STOPPED

URLs:
  HTTP:       http://localhost
  HTTPS:      https://localhost
  RTMP:       rtmp://localhost:1935/live/streamkey
  RTMPS:      rtmps://localhost:1936/live/streamkey

Connection Info:
  MySQL:      socket: /home/user/webstack/tmp/mysql.sock
  Redis:      127.0.0.1:6379
  Memcached:  127.0.0.1:11211
  PHP-FPM:    /home/user/webstack/tmp/php-fpm.sock
```

</details>

## 5.3 Access Your Site

| URL | Description |
|-----|-------------|
| http://localhost | Main website (HTML) |
| http://localhost/index.php | PHP test page |
| http://localhost/test_cache.php | Cache test (Redis/Memcached) |
| http://localhost/phpinfo.php | PHP information |
| http://localhost/phpmyadmin | Database management |
| http://localhost/api/status | Node.js API status |
| ws://localhost/ws | WebSocket endpoint |

## 5.4 Enable Public Access

<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
# Start tunnel with auto-reconnect
./webstack tunnel daemon

# Get your public URL
./webstack tunnel url
```

</details>

**Output:**
<details>
<summary><strong>💻 Code Block — 1 lines</strong></summary>

```
https://random-words-here.trycloudflare.com
```

</details>

Your site is now accessible worldwide via HTTPS!

## 5.5 Stop Everything

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./webstack stop
```

</details>

---

# 6. Command Reference

## 6.1 Main Control Script (`./webstack`)

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./webstack <command> [options]
```

</details>

### Main Commands

| Command | Description |
|---------|-------------|
| `start` | Start all services |
| `stop` | Stop all services |
| `restart` | Restart all services |
| `status` | Show status of all services |
| `logs` | Show recent log entries |

### Cloudflare Tunnel Commands

| Command | Description |
|---------|-------------|
| `tunnel start [port]` | Start tunnel (default port 80) |
| `tunnel stop` | Stop tunnel |
| `tunnel restart` | Restart tunnel (get new URL) |
| `tunnel daemon [port]` | Start with auto-reconnect |
| `tunnel stop-daemon` | Stop daemon |
| `tunnel status` | Show tunnel status |
| `tunnel url` | Show current URL |
| `tunnel logs` | Show URL history |

### Cache Commands

| Command | Description |
|---------|-------------|
| `cache status` | Show cache status and statistics |
| `cache flush` | Clear all cache data |
| `cache start` | Start Redis and Memcached |
| `cache stop` | Stop Redis and Memcached |
| `cache restart` | Restart cache servers |

### Redis Commands

| Command | Description |
|---------|-------------|
| `redis start` | Start Redis server |
| `redis stop` | Stop Redis server |
| `redis restart` | Restart Redis server |
| `redis cli [args]` | Open Redis CLI or run command |

### Memcached Commands

| Command | Description |
|---------|-------------|
| `memcached start` | Start Memcached server |
| `memcached stop` | Stop Memcached server |
| `memcached restart` | Restart Memcached server |
| `memcached stats` | Show Memcached statistics |

### Examples

<details>
<summary><strong>💻 Code Block (bash) — 32 lines</strong></summary>

```bash
# Start all services
./webstack start

# Check everything
./webstack status

# View logs
./webstack logs

# Start tunnel with auto-reconnect
./webstack tunnel daemon

# Get current tunnel URL
./webstack tunnel url

# Check cache status
./webstack cache status

# Flush all caches
./webstack cache flush

# Use Redis CLI
./webstack redis cli PING
./webstack redis cli SET mykey "hello"
./webstack redis cli GET mykey
./webstack redis cli INFO

# Interactive Redis CLI
./webstack redis cli

# Memcached stats
./webstack memcached stats
```

</details>

## 6.2 Individual Service Scripts

### PHP Commands

<details>
<summary><strong>💻 Code Block (bash) — 13 lines</strong></summary>

```bash
# PHP CLI
./php/bin/php -v                    # Version
./php/bin/php -m                    # List modules
./php/bin/php -i                    # PHP info
./php/bin/php script.php            # Run script
./php/bin/php -r "echo 'hello';"    # Run inline code

# PHP-FPM
./php/sbin/php-fpm -t               # Test config
./php/sbin/php-fpm -y /path/fpm.conf

# Reload PHP-FPM (graceful)
kill -USR2 $(cat php/var/run/php-fpm.pid)
```

</details>

### Nginx Commands

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# Test configuration
./nginx/sbin/nginx -t -p ~/webstack/nginx

# Reload configuration (graceful)
./nginx/sbin/nginx -p ~/webstack/nginx -s reload

# Stop gracefully
./nginx/sbin/nginx -p ~/webstack/nginx -s quit

# Stop immediately
./nginx/sbin/nginx -p ~/webstack/nginx -s stop

# Show version and modules
./nginx/sbin/nginx -V
```

</details>

### Node.js Commands

<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# Run node
./node/bin/node -v
./node/bin/node script.js

# Use npm (from project directory)
cd ~/webstack/ws
../node/bin/node ../node/bin/npm install package-name
../node/bin/node ../node/bin/npm update
../node/bin/node ../node/bin/npm list
```

</details>

### MySQL Commands

<details>
<summary><strong>💻 Code Block (bash) — 21 lines</strong></summary>

```bash
# Start/Stop
./scripts/start_mysql.sh
./scripts/stop_mysql.sh

# MySQL client
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root

# With password
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root -p

# Run SQL command
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root -e "SHOW DATABASES;"

# Backup database
./mysql/bin/mysqldump --socket=./tmp/mysql.sock -u root dbname > backup.sql

# Backup all databases
./mysql/bin/mysqldump --socket=./tmp/mysql.sock -u root --all-databases > all.sql

# Restore database
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root dbname < backup.sql
```

</details>

### Redis Commands

<details>
<summary><strong>💻 Code Block (bash) — 13 lines</strong></summary>

```bash
# Direct Redis CLI
./deps/bin/redis-cli

# Common commands
./deps/bin/redis-cli PING
./deps/bin/redis-cli INFO
./deps/bin/redis-cli KEYS "*"
./deps/bin/redis-cli SET key value
./deps/bin/redis-cli GET key
./deps/bin/redis-cli DEL key
./deps/bin/redis-cli FLUSHALL
./deps/bin/redis-cli DBSIZE
./deps/bin/redis-cli MONITOR
```

</details>

### Memcached Commands

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# Stats via netcat
echo "stats" | nc localhost 11211

# Flush all
echo "flush_all" | nc localhost 11211

# Get stats items
echo "stats items" | nc localhost 11211
```

</details>

### Composer Commands

<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# Via wrapper
./composer --version
./composer install
./composer update
./composer require vendor/package
./composer dump-autoload -o

# Direct
./php/bin/php ./php/bin/composer install
```

</details>

### FFmpeg Commands

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# Version
./deps/bin/ffmpeg -version

# Convert video
./deps/bin/ffmpeg -i input.mp4 -c:v libx264 output.mp4

# Stream to RTMP
./deps/bin/ffmpeg -re -i video.mp4 -c copy -f flv rtmp://localhost:1935/live/test
```

</details>

## 6.3 Utility Scripts

### Environment Setup

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# Load environment (adds all paths)
source ./scripts/env.sh

# Now use commands directly
php -v
node -v
mysql -u root
redis-cli PING
```

</details>

### Backup

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./scripts/backup.sh
```

</details>

Creates:
- `backups/www_TIMESTAMP.tar.gz`
- `backups/mysql_TIMESTAMP.sql.gz`
- `backups/config_TIMESTAMP.tar.gz`

### Health Check

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./scripts/health.sh
```

</details>

### Log Viewer

<details>
<summary><strong>💻 Code Block (bash) — 7 lines</strong></summary>

```bash
./scripts/logs.sh              # All logs
./scripts/logs.sh nginx        # Nginx only
./scripts/logs.sh php          # PHP only
./scripts/logs.sh node         # Node.js only
./scripts/logs.sh mysql        # MySQL only
./scripts/logs.sh redis        # Redis only
./scripts/logs.sh cloudflare   # Cloudflare only
```

</details>

### SSL Certificate Renewal

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./scripts/renew_ssl.sh
```

</details>

---

# 7. Components

## 7.1 Nginx

### Version & Features

| Feature | Status |
|---------|--------|
| Version | 1.25.4 |
| HTTP/2 | ✅ Enabled |
| HTTP/3 (QUIC) | ✅ Enabled |
| TLS 1.3 | ✅ Enabled |
| Brotli | ✅ Enabled |
| GeoIP2 | ✅ Enabled |
| RTMP | ✅ Enabled |

### Installed Modules

| Module | Description |
|--------|-------------|
| `http_ssl_module` | SSL/TLS support |
| `http_v2_module` | HTTP/2 support |
| `http_v3_module` | HTTP/3 (QUIC) support |
| `http_realip_module` | Real IP from headers |
| `http_gzip_static_module` | Pre-compressed files |
| `http_mp4_module` | MP4 streaming |
| `http_flv_module` | FLV streaming |
| `http_secure_link_module` | Secure links |
| `http_stub_status_module` | Basic status |
| `http_auth_request_module` | Auth subrequests |
| `stream_module` | TCP/UDP proxy |
| `nginx-rtmp-module` | RTMP streaming |
| `push_stream_module` | Server-Sent Events |
| `headers-more-module` | Header manipulation |
| `ngx_brotli` | Brotli compression |
| `ngx_cache_purge` | Cache purging |
| `nginx-module-vts` | Traffic status |
| `njs` | JavaScript scripting |
| `ngx_http_geoip2_module` | GeoIP2 support |

### Configuration

**Main config:** `nginx/conf/nginx.conf`

**Add virtual host:** Create `nginx/conf/conf.d/mysite.conf`

<details>
<summary><strong>💻 Code Block (nginx) — 16 lines</strong></summary>

```nginx
server {
    listen 80;
    server_name mysite.local;
    root /home/user/webstack/www/mysite;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/home/user/webstack/tmp/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

</details>

Reload: `./nginx/sbin/nginx -p ~/webstack/nginx -s reload`

## 7.2 PHP

### Version & Configuration

| Feature | Value |
|---------|-------|
| Version | 8.3.2 |
| SAPI | FPM |
| JIT | ✅ Enabled |
| OPcache | ✅ Enabled |

### Loaded Extensions

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./php/bin/php -m
```

</details>

**Core:** Core, date, filter, hash, json, pcre, Reflection, SPL, standard

**Database:** mysqli, mysqlnd, PDO, pdo_mysql, pdo_sqlite, sqlite3

**Caching:** redis, memcached, opcache

**Encryption:** openssl, sodium, password (argon2)

**Compression:** zlib, zip, bz2

**Image:** gd (freetype, jpeg, webp, png)

**XML:** dom, libxml, simplexml, xml, xmlreader, xmlwriter

**String:** mbstring, iconv, intl, ctype, tokenizer

**Network:** curl, sockets, ftp

**Other:** bcmath, calendar, exif, fileinfo, pcntl, posix, readline, session

### Configuration Files

| File | Purpose |
|------|---------|
| `php/etc/php.ini` | Main configuration |
| `php/etc/php-fpm.conf` | FPM global config |
| `php/etc/php-fpm.d/www.conf` | Pool config |
| `php/etc/conf.d/custom.ini` | Custom settings |
| `php/etc/conf.d/redis.ini` | Redis extension |
| `php/etc/conf.d/memcached.ini` | Memcached extension |

### Key php.ini Settings

<details>
<summary><strong>💻 Code Block (ini) — 10 lines</strong></summary>

```ini
memory_limit = 256M
max_execution_time = 300
upload_max_filesize = 100M
post_max_size = 100M

opcache.enable = 1
opcache.jit = 1255
opcache.jit_buffer_size = 64M

date.timezone = UTC
```

</details>

## 7.3 Node.js

### Version

| Component | Version |
|-----------|---------|
| Node.js | 20.10.0 LTS |
| npm | 10.x |

### Using npm

<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# Navigate to project
cd ~/webstack/ws

# Install package
../node/bin/node ../node/bin/npm install express

# Or create alias
alias npm="~/webstack/node/bin/node ~/webstack/node/bin/npm"
npm install ws
```

</details>

### Default API Server

Location: `www/app.js`

Endpoints:
- `GET /api/status` - Server status
- `GET /api/health` - Health check
- `POST /api/echo` - Echo request
- `GET /api/events` - Server-Sent Events

### WebSocket Server

Location: `ws/server.js`

Features:
- Client tracking
- Message broadcasting
- Ping/pong support

## 7.4 MySQL/MariaDB

### Version

MariaDB 11.2.2

### Configuration

Location: `mysql/my.cnf`

<details>
<summary><strong>💻 Code Block (ini) — 7 lines</strong></summary>

```ini
[mysqld]
socket = /home/user/webstack/tmp/mysql.sock
port = 3306
bind-address = 127.0.0.1
character-set-server = utf8mb4
max_connections = 100
innodb_buffer_pool_size = 128M
```

</details>

### Commands

<details>
<summary><strong>💻 Code Block (bash) — 16 lines</strong></summary>

```bash
# Start/stop
./scripts/start_mysql.sh
./scripts/stop_mysql.sh

# Connect
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root

# Create database
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root \
    -e "CREATE DATABASE myapp CHARACTER SET utf8mb4;"

# Create user
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root \
    -e "CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'password';"
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root \
    -e "GRANT ALL ON myapp.* TO 'myuser'@'localhost';"
```

</details>

### PHP Connection

<details>
<summary><strong>💻 Code Block (php) — 6 lines</strong></summary>

```php
// Using PDO (recommended)
$socket = '/home/user/webstack/tmp/mysql.sock';
$pdo = new PDO("mysql:unix_socket=$socket;dbname=myapp", 'root', '');

// Using mysqli
$mysqli = new mysqli('localhost', 'root', '', 'myapp', 0, $socket);
```

</details>

### phpMyAdmin

Access: http://localhost/phpmyadmin

Default login: `root` (no password)

## 7.5 Redis

### Version

Redis 7.2.4

### Configuration

Location: `redis/redis.conf`

<details>
<summary><strong>💻 Code Block (ini) — 5 lines</strong></summary>

```ini
bind 127.0.0.1
port 6379
daemonize yes
maxmemory 128mb
maxmemory-policy allkeys-lru
```

</details>

### Commands

<details>
<summary><strong>💻 Code Block (bash) — 18 lines</strong></summary>

```bash
# Start/stop via webstack
./webstack redis start
./webstack redis stop

# Or via scripts
./scripts/start_redis.sh
./scripts/stop_redis.sh

# Redis CLI
./webstack redis cli PING
./webstack redis cli INFO
./webstack redis cli SET key value
./webstack redis cli GET key

# Interactive
./webstack redis cli
# or
./deps/bin/redis-cli
```

</details>

### PHP Usage

<details>
<summary><strong>💻 Code Block (php) — 39 lines</strong></summary>

```php
<?php
// Connect
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);

// Basic operations
$redis->set('key', 'value');
$redis->setex('temp', 3600, 'expires in 1 hour');
$value = $redis->get('key');

// Increment
$redis->incr('counter');
$redis->incrBy('counter', 5);

// Hash
$redis->hSet('user:1', 'name', 'John');
$redis->hSet('user:1', 'email', 'john@example.com');
$user = $redis->hGetAll('user:1');

// List
$redis->rPush('queue', 'item1', 'item2');
$item = $redis->lPop('queue');

// Set
$redis->sAdd('tags', 'php', 'redis', 'web');
$tags = $redis->sMembers('tags');

// Sorted Set
$redis->zAdd('leaderboard', 100, 'player1');
$redis->zAdd('leaderboard', 200, 'player2');
$top = $redis->zRevRange('leaderboard', 0, 9, true);

// Expire
$redis->expire('key', 3600);
$ttl = $redis->ttl('key');

// Delete
$redis->del('key');
$redis->del(['key1', 'key2']);
```

</details>

### Caching Pattern

<details>
<summary><strong>💻 Code Block (php) — 18 lines</strong></summary>

```php
function getCached($key, $callback, $ttl = 3600) {
    global $redis;
    
    $value = $redis->get($key);
    
    if ($value === false) {
        $value = $callback();
        $redis->setex($key, $ttl, serialize($value));
        return $value;
    }
    
    return unserialize($value);
}

// Usage
$users = getCached('all_users', function() use ($pdo) {
    return $pdo->query('SELECT * FROM users')->fetchAll();
}, 300);
```

</details>

## 7.6 Memcached

### Version

Memcached 1.6.23

### Configuration

Start command uses these defaults:
- Memory: 64 MB
- Port: 11211
- Connections: 1024

### Commands

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# Start/stop via webstack
./webstack memcached start
./webstack memcached stop

# Or via scripts
./scripts/start_memcached.sh
./scripts/stop_memcached.sh

# Stats
./webstack memcached stats
echo "stats" | nc localhost 11211

# Flush
echo "flush_all" | nc localhost 11211
```

</details>

### PHP Usage

<details>
<summary><strong>💻 Code Block (php) — 38 lines</strong></summary>

```php
<?php
// Connect
$memcached = new Memcached();
$memcached->addServer('127.0.0.1', 11211);

// Basic operations
$memcached->set('key', 'value', 3600);
$value = $memcached->get('key');

// Multiple keys
$memcached->setMulti([
    'key1' => 'value1',
    'key2' => 'value2'
], 3600);
$values = $memcached->getMulti(['key1', 'key2']);

// Increment
$memcached->set('counter', 0);
$memcached->increment('counter');
$memcached->increment('counter', 5);

// Store arrays/objects
$memcached->set('user', ['name' => 'John', 'email' => 'john@example.com']);
$user = $memcached->get('user');

// Add (only if not exists)
$memcached->add('unique_key', 'value');

// Replace (only if exists)
$memcached->replace('key', 'new_value');

// Delete
$memcached->delete('key');

// Check result
if ($memcached->getResultCode() === Memcached::RES_SUCCESS) {
    echo "Operation successful";
}
```

</details>

### Session Storage

<details>
<summary><strong>💻 Code Block (ini) — 3 lines</strong></summary>

```ini
; php.ini
session.save_handler = memcached
session.save_path = "127.0.0.1:11211"
```

</details>

## 7.7 WebSocket

### Server

Location: `ws/server.js`

Port: 8081 (proxied via Nginx at `/ws`)

### Features

- Client ID assignment
- Welcome message
- Message echo
- Broadcast to all clients
- Client join/leave notifications
- Ping/pong support

### Client Example

<details>
<summary><strong>💻 Code Block (html) — 32 lines</strong></summary>

```html
<!DOCTYPE html>
<html>
<head>
    <title>WebSocket Test</title>
</head>
<body>
    <input type="text" id="message" placeholder="Message">
    <button onclick="send()">Send</button>
    <div id="output"></div>

    <script>
        const ws = new WebSocket('ws://localhost/ws');
        
        ws.onopen = () => log('Connected');
        
        ws.onmessage = (e) => {
            const data = JSON.parse(e.data);
            log('Received: ' + JSON.stringify(data));
        };
        
        ws.onclose = () => log('Disconnected');
        
        function send() {
            ws.send(document.getElementById('message').value);
        }
        
        function log(msg) {
            document.getElementById('output').innerHTML += '<p>' + msg + '</p>';
        }
    </script>
</body>
</html>
```

</details>

## 7.8 RTMP Streaming

### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 1935 | RTMP | Standard streaming |
| 1936 | RTMPS | Secure streaming (TLS) |

### Stream URLs

<details>
<summary><strong>💻 Code Block — 6 lines</strong></summary>

```
# Ingest
rtmp://localhost:1935/live/STREAM_KEY
rtmps://localhost:1936/live/STREAM_KEY

# Playback (HLS)
http://localhost/hls/STREAM_KEY.m3u8
```

</details>

### OBS Studio Settings

| Setting | Value |
|---------|-------|
| Service | Custom |
| Server | `rtmp://localhost:1935/live` |
| Stream Key | `mystream` |

### FFmpeg Streaming

<details>
<summary><strong>💻 Code Block (bash) — 13 lines</strong></summary>

```bash
# Stream video file
./deps/bin/ffmpeg -re -i video.mp4 -c copy -f flv \
    rtmp://localhost:1935/live/test

# Stream with encoding
./deps/bin/ffmpeg -re -i video.mp4 \
    -c:v libx264 -preset veryfast -b:v 2500k \
    -c:a aac -b:a 128k \
    -f flv rtmp://localhost:1935/live/test

# Loop stream
./deps/bin/ffmpeg -stream_loop -1 -re -i video.mp4 \
    -c copy -f flv rtmp://localhost:1935/live/test
```

</details>

### HLS Playback

<details>
<summary><strong>💻 Code Block (html) — 22 lines</strong></summary>

```html
<!DOCTYPE html>
<html>
<head>
    <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
</head>
<body>
    <video id="video" controls width="720"></video>
    
    <script>
        const video = document.getElementById('video');
        const streamUrl = '/hls/mystream.m3u8';
        
        if (Hls.isSupported()) {
            const hls = new Hls();
            hls.loadSource(streamUrl);
            hls.attachMedia(video);
        } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
            video.src = streamUrl;
        }
    </script>
</body>
</html>
```

</details>

## 7.9 Cloudflare Tunnel

### Overview

Provides instant public HTTPS access without:
- Opening firewall ports
- Configuring port forwarding
- Setting up dynamic DNS
- Purchasing SSL certificates

### Installation

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./install_cloudflared.sh
```

</details>

### Commands

<details>
<summary><strong>💻 Code Block (bash) — 24 lines</strong></summary>

```bash
# Simple start
./webstack tunnel start

# With auto-reconnect (recommended)
./webstack tunnel daemon

# Stop
./webstack tunnel stop
./webstack tunnel stop-daemon

# Status
./webstack tunnel status

# Current URL
./webstack tunnel url

# URL history
./webstack tunnel logs

# Restart (new URL)
./webstack tunnel restart

# Custom port
./webstack tunnel daemon 8080
```

</details>

### URL History

Location: `logs/cloudflare/url_history.log`

Format (newest first):
<details>
<summary><strong>💻 Code Block — 3 lines</strong></summary>

```
2024-02-27 14:30:22 | https://random-words-here.trycloudflare.com
2024-02-27 12:15:10 | https://other-random-url.trycloudflare.com
2024-02-26 09:45:33 | https://previous-tunnel.trycloudflare.com
```

</details>

### Auto-Reconnect Behavior

1. Monitors tunnel health every 30 seconds
2. If tunnel dies, attempts reconnection
3. After 5 failures, creates new tunnel with new URL
4. All URLs logged to history file

## 7.10 FFmpeg

### Installation

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./install_ffmpeg.sh
```

</details>

### Common Operations

<details>
<summary><strong>💻 Code Block (bash) — 29 lines</strong></summary>

```bash
# Check version
./deps/bin/ffmpeg -version

# List encoders
./deps/bin/ffmpeg -encoders

# Convert video
./deps/bin/ffmpeg -i input.mp4 -c:v libx264 -c:a aac output.mp4

# Extract audio
./deps/bin/ffmpeg -i video.mp4 -vn -c:a mp3 audio.mp3

# Create thumbnail
./deps/bin/ffmpeg -i video.mp4 -ss 00:00:05 -vframes 1 thumb.jpg

# Scale video
./deps/bin/ffmpeg -i input.mp4 -vf scale=1280:720 output_720p.mp4

# Convert to HLS
./deps/bin/ffmpeg -i input.mp4 \
    -c:v libx264 -c:a aac \
    -hls_time 10 -hls_list_size 0 \
    -f hls output.m3u8

# Compress video
./deps/bin/ffmpeg -i input.mp4 \
    -c:v libx264 -crf 23 \
    -c:a aac -b:a 128k \
    output_compressed.mp4
```

</details>

## 7.11 Composer

### Installation

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./setup_composer.sh
```

</details>

### Usage

<details>
<summary><strong>💻 Code Block (bash) — 10 lines</strong></summary>

```bash
# Via wrapper (handles SSL certificates)
./composer --version
./composer install
./composer update
./composer require monolog/monolog
./composer dump-autoload -o

# Create new project
cd www
../composer create-project laravel/laravel myapp
```

</details>

---

# 8. Configuration

## 8.1 Nginx Configuration

### Main Config: `nginx/conf/nginx.conf`

Key sections:

<details>
<summary><strong>💻 Code Block (nginx) — 38 lines</strong></summary>

```nginx
# Worker settings
worker_processes auto;

# Events
events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

# HTTP settings
http {
    # Compression
    gzip on;
    gzip_types application/javascript text/css;
    
    # Upstreams
    upstream php-fpm {
        server unix:/path/to/php-fpm.sock;
    }
    
    # Server blocks
    server {
        listen 80;
        # ...
    }
}

# RTMP
rtmp {
    server {
        listen 1935;
        application live {
            live on;
            hls on;
        }
    }
}
```

</details>

### Add Virtual Host

Create `nginx/conf/conf.d/myapp.conf`:

<details>
<summary><strong>💻 Code Block (nginx) — 28 lines</strong></summary>

```nginx
server {
    listen 80;
    server_name myapp.local;
    root /home/user/webstack/www/myapp/public;
    index index.php index.html;

    # Laravel/Symfony routing
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass php-fpm;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # Deny hidden files
    location ~ /\. {
        deny all;
    }
}
```

</details>

## 8.2 PHP Configuration

### php.ini: `php/etc/php.ini`

<details>
<summary><strong>💻 Code Block (ini) — 38 lines</strong></summary>

```ini
; Resource Limits
memory_limit = 256M
max_execution_time = 300
max_input_time = 300
max_input_vars = 5000

; Upload
upload_max_filesize = 100M
post_max_size = 100M
max_file_uploads = 50

; Error Handling (Development)
display_errors = On
error_reporting = E_ALL
log_errors = On

; Error Handling (Production)
; display_errors = Off
; error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

; OPcache
opcache.enable = 1
opcache.memory_consumption = 256
opcache.max_accelerated_files = 20000
opcache.validate_timestamps = 1  ; 0 for production
opcache.jit = 1255
opcache.jit_buffer_size = 128M

; Session
session.save_handler = files
session.save_path = "/home/user/webstack/tmp/sessions"
session.gc_maxlifetime = 86400

; Timezone
date.timezone = UTC

; Security
expose_php = Off
```

</details>

### PHP-FPM Pool: `php/etc/php-fpm.conf`

<details>
<summary><strong>💻 Code Block (ini) — 18 lines</strong></summary>

```ini
[global]
pid = /path/to/php-fpm.pid
error_log = /path/to/php-fpm.log
daemonize = yes

[www]
listen = /path/to/php-fpm.sock
listen.mode = 0666

user = username
group = groupname

pm = dynamic
pm.max_children = 25
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
pm.max_requests = 500
```

</details>

## 8.3 MySQL Configuration

### my.cnf: `mysql/my.cnf`

<details>
<summary><strong>💻 Code Block (ini) — 31 lines</strong></summary>

```ini
[mysqld]
basedir = /home/user/webstack/mysql
datadir = /home/user/webstack/data/mysql
socket = /home/user/webstack/tmp/mysql.sock
port = 3306
bind-address = 127.0.0.1

# Character set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Connections
max_connections = 100
wait_timeout = 600

# InnoDB
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
innodb_file_per_table = 1

# Query cache
query_cache_type = 1
query_cache_size = 32M

# Logging
slow_query_log = 1
long_query_time = 2

[client]
socket = /home/user/webstack/tmp/mysql.sock
default-character-set = utf8mb4
```

</details>

## 8.4 Redis Configuration

### redis.conf: `redis/redis.conf`

<details>
<summary><strong>💻 Code Block (ini) — 23 lines</strong></summary>

```ini
# Network
bind 127.0.0.1
port 6379
timeout 0

# General
daemonize yes
pidfile /home/user/webstack/tmp/redis.pid
logfile /home/user/webstack/logs/redis.log

# Persistence
dir /home/user/webstack/data/redis
dbfilename dump.rdb
save 900 1
save 300 10
save 60 10000

# Memory
maxmemory 128mb
maxmemory-policy allkeys-lru

# Security
# requirepass your_password
```

</details>

## 8.5 Environment Variables

### Load environment: `source scripts/env.sh`

<details>
<summary><strong>💻 Code Block (bash) — 4 lines</strong></summary>

```bash
export WEBSTACK_ROOT="$HOME/webstack"
export PATH="$WEBSTACK_ROOT/deps/bin:$WEBSTACK_ROOT/php/bin:$WEBSTACK_ROOT/node/bin:$WEBSTACK_ROOT/mysql/bin:$PATH"
export LD_LIBRARY_PATH="$WEBSTACK_ROOT/deps/lib:$LD_LIBRARY_PATH"
export SSL_CERT_FILE="$WEBSTACK_ROOT/deps/ssl/certs/cacert.pem"
```

</details>

---

# 9. Development Guide

## 9.1 PHP Development

### Laravel Project

<details>
<summary><strong>💻 Code Block (bash) — 24 lines</strong></summary>

```bash
# Create project
cd ~/webstack/www
../composer create-project laravel/laravel myapp
cd myapp

# Configure .env
DB_CONNECTION=mysql
DB_HOST=localhost
DB_SOCKET=/home/user/webstack/tmp/mysql.sock
DB_DATABASE=myapp
DB_USERNAME=root
DB_PASSWORD=

CACHE_DRIVER=redis
SESSION_DRIVER=redis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

# Create database
~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root \
    -e "CREATE DATABASE myapp"

# Run migrations
../../../php/bin/php artisan migrate
```

</details>

Nginx config for Laravel: See Section 8.1

### WordPress

<details>
<summary><strong>💻 Code Block (bash) — 7 lines</strong></summary>

```bash
cd ~/webstack/www
wget https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz && rm latest.tar.gz

# Create database
~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root \
    -e "CREATE DATABASE wordpress"
```

</details>

Configure `wp-config.php`:
<details>
<summary><strong>💻 Code Block (php) — 4 lines</strong></summary>

```php
define('DB_NAME', 'wordpress');
define('DB_USER', 'root');
define('DB_PASSWORD', '');
define('DB_HOST', 'localhost:/home/user/webstack/tmp/mysql.sock');
```

</details>

### Using Redis in PHP

<details>
<summary><strong>💻 Code Block (php) — 22 lines</strong></summary>

```php
<?php
// Connect
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);

// Caching example
function cache($key, $callback, $ttl = 3600) {
    global $redis;
    $data = $redis->get($key);
    if ($data === false) {
        $data = $callback();
        $redis->setex($key, $ttl, serialize($data));
        return $data;
    }
    return unserialize($data);
}

// Usage
$users = cache('users:all', function() {
    global $pdo;
    return $pdo->query('SELECT * FROM users')->fetchAll();
}, 300);
```

</details>

### Using Memcached in PHP

<details>
<summary><strong>💻 Code Block (php) — 7 lines</strong></summary>

```php
<?php
$mc = new Memcached();
$mc->addServer('127.0.0.1', 11211);

// Store session data
$mc->set('session:abc123', ['user_id' => 1, 'name' => 'John'], 3600);
$session = $mc->get('session:abc123');
```

</details>

## 9.2 Node.js Development

### Express API

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
cd ~/webstack/www
mkdir api && cd api

# Initialize
~/webstack/node/bin/node ~/webstack/node/bin/npm init -y
~/webstack/node/bin/node ~/webstack/node/bin/npm install express cors
```

</details>

Create `app.js`:
<details>
<summary><strong>💻 Code Block (javascript) — 12 lines</strong></summary>

```javascript
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

app.get('/api/users', (req, res) => {
    res.json([{ id: 1, name: 'John' }]);
});

app.listen(3000, '127.0.0.1');
```

</details>

### WebSocket with Socket.IO

<details>
<summary><strong>💻 Code Block (bash) — 2 lines</strong></summary>

```bash
cd ~/webstack/ws
~/webstack/node/bin/node ~/webstack/node/bin/npm install socket.io
```

</details>

## 9.3 Database Development

### Create Database & User

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root << 'SQL'
CREATE DATABASE myapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON myapp.* TO 'myuser'@'localhost';
FLUSH PRIVILEGES;
SQL
```

</details>

### Migrations

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
# Create migrations directory
mkdir -p ~/webstack/www/myapp/migrations

# Run migration
~/webstack/mysql/bin/mysql --socket=~/webstack/tmp/mysql.sock -u root myapp \
    < migrations/001_create_users.sql
```

</details>

---

# 10. Production Deployment

## 10.1 Pre-deployment Checklist

- [ ] Run `./cleanup.sh` to reduce size
- [ ] Disable PHP `display_errors`
- [ ] Enable OPcache with `validate_timestamps=0`
- [ ] Configure proper SSL certificates (Let's Encrypt)
- [ ] Set strong MySQL root password
- [ ] Remove or restrict phpMyAdmin
- [ ] Configure firewall rules
- [ ] Set up automated backups
- [ ] Configure log rotation
- [ ] Set Redis password

## 10.2 Production Settings

### PHP (php.ini)

<details>
<summary><strong>💻 Code Block (ini) — 7 lines</strong></summary>

```ini
display_errors = Off
log_errors = On
opcache.validate_timestamps = 0
opcache.memory_consumption = 256
expose_php = Off
session.cookie_secure = 1
session.cookie_httponly = 1
```

</details>

### Nginx Security Headers

<details>
<summary><strong>💻 Code Block (nginx) — 4 lines</strong></summary>

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Strict-Transport-Security "max-age=31536000" always;
```

</details>

### Redis

<details>
<summary><strong>💻 Code Block (ini) — 2 lines</strong></summary>

```ini
# redis.conf
requirepass your_strong_password_here
```

</details>

## 10.3 SSL with Let's Encrypt

<details>
<summary><strong>💻 Code Block (bash) — 13 lines</strong></summary>

```bash
# Install certbot
sudo apt install certbot

# Get certificate
sudo certbot certonly --standalone -d yourdomain.com

# Copy to WebStack
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ~/webstack/nginx/conf/ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ~/webstack/nginx/conf/ssl/key.pem
sudo chown $(whoami) ~/webstack/nginx/conf/ssl/*.pem

# Restart
./webstack restart
```

</details>

## 10.4 Systemd Service

Create `/etc/systemd/system/webstack.service`:

<details>
<summary><strong>💻 Code Block (ini) — 14 lines</strong></summary>

```ini
[Unit]
Description=WebStack Web Server
After=network.target

[Service]
Type=forking
User=webuser
WorkingDirectory=/home/webuser/webstack
ExecStart=/home/webuser/webstack/webstack start
ExecStop=/home/webuser/webstack/webstack stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

</details>

<details>
<summary><strong>💻 Code Block (bash) — 3 lines</strong></summary>

```bash
sudo systemctl daemon-reload
sudo systemctl enable webstack
sudo systemctl start webstack
```

</details>

---

# 11. Backup & Recovery

## 11.1 Manual Backup

<details>
<summary><strong>💻 Code Block (bash) — 1 lines</strong></summary>

```bash
./scripts/backup.sh
```

</details>

Creates in `backups/`:
- `www_TIMESTAMP.tar.gz` - Web files
- `mysql_TIMESTAMP.sql.gz` - Database
- `config_TIMESTAMP.tar.gz` - Configuration

## 11.2 Automated Backup (Cron)

<details>
<summary><strong>💻 Code Block (bash) — 7 lines</strong></summary>

```bash
crontab -e

# Daily at 2 AM
0 2 * * * /home/user/webstack/scripts/backup.sh

# Weekly cleanup
0 3 * * 0 find /home/user/webstack/backups -mtime +30 -delete
```

</details>

## 11.3 Restore

<details>
<summary><strong>💻 Code Block (bash) — 11 lines</strong></summary>

```bash
# Restore web files
cd ~/webstack
tar -xzf backups/www_20240227_020000.tar.gz

# Restore database
gunzip -c backups/mysql_20240227_020000.sql.gz | \
    ./mysql/bin/mysql --socket=./tmp/mysql.sock -u root

# Restore config
tar -xzf backups/config_20240227_020000.tar.gz
./webstack restart
```

</details>

---

# 12. Troubleshooting

## 12.1 Common Issues

### Services Won't Start

<details>
<summary><strong>💻 Code Block (bash) — 13 lines</strong></summary>

```bash
# Check what's wrong
./webstack status

# Check specific service
./php/sbin/php-fpm -t
./nginx/sbin/nginx -t -p ~/webstack/nginx

# Check for missing libraries
ldd ./nginx/sbin/nginx | grep "not found"
ldd ./php/sbin/php-fpm | grep "not found"

# Fix library path
export LD_LIBRARY_PATH="$HOME/webstack/deps/lib:$LD_LIBRARY_PATH"
```

</details>

### Port 80/443 Permission Denied

<details>
<summary><strong>💻 Code Block (bash) — 5 lines</strong></summary>

```bash
# Option 1: Use setcap
sudo setcap 'cap_net_bind_service=+ep' ~/webstack/nginx/sbin/nginx

# Option 2: Use ports > 1024
# Edit nginx.conf: listen 8080;
```

</details>

### Redis/Memcached Not Detected

<details>
<summary><strong>💻 Code Block (bash) — 9 lines</strong></summary>

```bash
# Check installation paths
ls -la ~/webstack/deps/bin/redis-server
ls -la ~/webstack/deps/bin/memcached

# Check PHP extensions
./php/bin/php -m | grep -E "(redis|memcached)"

# Restart PHP-FPM after extension changes
kill -USR2 $(cat php/var/run/php-fpm.pid)
```

</details>

### MySQL Connection Issues

<details>
<summary><strong>💻 Code Block (bash) — 8 lines</strong></summary>

```bash
# Check socket exists
ls -la ~/webstack/tmp/mysql.sock

# Check MySQL is running
./webstack status

# Test connection
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root -e "SELECT 1"
```

</details>

## 12.2 Checking Logs

<details>
<summary><strong>💻 Code Block (bash) — 14 lines</strong></summary>

```bash
# All logs
./webstack logs

# Specific service
./scripts/logs.sh nginx
./scripts/logs.sh php
./scripts/logs.sh mysql
./scripts/logs.sh redis
./scripts/logs.sh cloudflare

# Tail specific log
tail -f nginx/logs/error.log
tail -f php/var/log/php-fpm.log
tail -f logs/redis.log
```

</details>

## 12.3 Reset Services

<details>
<summary><strong>💻 Code Block (bash) — 11 lines</strong></summary>

```bash
# Stop everything
./webstack stop

# Clear runtime files
rm -f tmp/*.pid tmp/*.sock

# Regenerate configs
./setup.sh

# Start fresh
./webstack start
```

</details>

---

# 13. Security

## 13.1 Security Checklist

- [ ] Set MySQL root password
- [ ] Set Redis password
- [ ] Restrict phpMyAdmin access
- [ ] Enable HTTPS
- [ ] Configure firewall
- [ ] Disable unnecessary PHP functions
- [ ] Keep components updated

## 13.2 MySQL Security

<details>
<summary><strong>💻 Code Block (bash) — 6 lines</strong></summary>

```bash
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root << 'SQL'
ALTER USER 'root'@'localhost' IDENTIFIED BY 'strong_password';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
SQL
```

</details>

## 13.3 Redis Security

Edit `redis/redis.conf`:
<details>
<summary><strong>💻 Code Block (ini) — 1 lines</strong></summary>

```ini
requirepass your_strong_password
```

</details>

Update PHP code:
<details>
<summary><strong>💻 Code Block (php) — 3 lines</strong></summary>

```php
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);
$redis->auth('your_strong_password');
```

</details>

## 13.4 Nginx Security

<details>
<summary><strong>💻 Code Block (nginx) — 13 lines</strong></summary>

```nginx
# Hide version
server_tokens off;

# Security headers
add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options "nosniff";
add_header X-XSS-Protection "1; mode=block";

# Restrict phpMyAdmin
location /phpmyadmin {
    allow 192.168.1.0/24;
    deny all;
}
```

</details>

## 13.5 PHP Security

<details>
<summary><strong>💻 Code Block (ini) — 6 lines</strong></summary>

```ini
; php.ini
expose_php = Off
display_errors = Off
disable_functions = exec,passthru,shell_exec,system,proc_open,popen
session.cookie_httponly = 1
session.cookie_secure = 1
```

</details>

---

# 14. Performance Tuning

## 14.1 Nginx

<details>
<summary><strong>💻 Code Block (nginx) — 17 lines</strong></summary>

```nginx
worker_processes auto;
worker_connections 4096;

# Buffers
client_body_buffer_size 128k;
proxy_buffer_size 128k;

# Gzip
gzip on;
gzip_comp_level 6;
gzip_types text/plain text/css application/json application/javascript;

# Static files
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

</details>

## 14.2 PHP

<details>
<summary><strong>💻 Code Block (ini) — 14 lines</strong></summary>

```ini
; OPcache
opcache.enable = 1
opcache.memory_consumption = 256
opcache.max_accelerated_files = 20000
opcache.validate_timestamps = 0
opcache.jit = 1255
opcache.jit_buffer_size = 128M

; PHP-FPM
pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
```

</details>

## 14.3 MySQL

<details>
<summary><strong>💻 Code Block (ini) — 4 lines</strong></summary>

```ini
innodb_buffer_pool_size = 1G  ; 70-80% of RAM for dedicated server
innodb_log_file_size = 256M
query_cache_size = 64M
thread_cache_size = 50
```

</details>

## 14.4 Redis

<details>
<summary><strong>💻 Code Block (ini) — 2 lines</strong></summary>

```ini
maxmemory 256mb
maxmemory-policy allkeys-lru
```

</details>

---

# 15. API Reference

## 15.1 Node.js API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/status` | Server status |
| GET | `/api/health` | Health check |
| POST | `/api/echo` | Echo request |
| GET | `/api/events` | SSE stream |

### Response Examples

**GET /api/status**
<details>
<summary><strong>💻 Code Block (json) — 8 lines</strong></summary>

```json
{
    "status": "ok",
    "service": "WebStack Node.js API",
    "node": "v20.10.0",
    "uptime": 3600,
    "memory": "45 MB",
    "time": "2024-02-27T12:00:00.000Z"
}
```

</details>

## 15.2 WebSocket Messages

**Server → Client:**
<details>
<summary><strong>💻 Code Block (json) — 5 lines</strong></summary>

```json
{"type": "welcome", "id": 1, "clients": 5}
{"type": "echo", "data": "your message"}
{"type": "broadcast", "from": 2, "data": "message"}
{"type": "client_joined", "id": 3, "clients": 6}
{"type": "client_left", "id": 2, "clients": 5}
```

</details>

## 15.3 RTMP Statistics

Enable in nginx.conf:
<details>
<summary><strong>💻 Code Block (nginx) — 3 lines</strong></summary>

```nginx
location /rtmp_stat {
    rtmp_stat all;
}
```

</details>

Access: `http://localhost/rtmp_stat`

---

# 16. Examples

## 16.1 PHP + Redis Session

<details>
<summary><strong>💻 Code Block (php) — 27 lines</strong></summary>

```php
<?php
session_set_save_handler(new RedisSessionHandler());
session_start();

class RedisSessionHandler implements SessionHandlerInterface {
    private $redis;
    private $ttl = 3600;
    
    public function open($path, $name): bool {
        $this->redis = new Redis();
        return $this->redis->connect('127.0.0.1', 6379);
    }
    
    public function read($id): string {
        return $this->redis->get("session:$id") ?: '';
    }
    
    public function write($id, $data): bool {
        return $this->redis->setex("session:$id", $this->ttl, $data);
    }
    
    public function destroy($id): bool {
        return $this->redis->del("session:$id") > 0;
    }
    
    // ... implement other methods
}
```

</details>

## 16.2 Real-time Chat

See `ws/server.js` and create client HTML with WebSocket connection.

## 16.3 Live Streaming Setup

1. Configure OBS → `rtmp://localhost:1935/live/mystream`
2. Create player page with HLS.js
3. Access at `http://localhost/hls/mystream.m3u8`

---

# 17. FAQ

**Q: Can I run on Windows?**
A: Use WSL2 (Windows Subsystem for Linux).

**Q: Do I need root access?**
A: Only for ports 80/443. Use `setcap` or higher ports.

**Q: How do I update components?**
A: Rebuild from source with newer versions.

**Q: Can I use Docker instead?**
A: WebStack is designed to be lighter than Docker while providing similar isolation.

**Q: How do I add SSL to Redis?**
A: Use stunnel or Redis with TLS (requires recompilation).

**Q: Can I run multiple instances?**
A: Yes, use different ports and paths.

**Q: How do I migrate to production?**
A: Run `./package.sh`, copy to server, run `./INSTALL.sh`.

---

# 18. Appendix

## 18.1 Port Reference

| Port | Service | Protocol |
|------|---------|----------|
| 80 | HTTP | TCP |
| 443 | HTTPS/HTTP3 | TCP/UDP |
| 1935 | RTMP | TCP |
| 1936 | RTMPS | TCP |
| 3000 | Node.js API | TCP |
| 3306 | MySQL | TCP |
| 6379 | Redis | TCP |
| 8081 | WebSocket | TCP |
| 11211 | Memcached | TCP |

## 18.2 Quick Commands Cheatsheet

<details>
<summary><strong>💻 Code Block (bash) — 25 lines</strong></summary>

```bash
# Services
./webstack start|stop|restart|status

# Tunnel
./webstack tunnel daemon
./webstack tunnel url

# Cache
./webstack cache status
./webstack cache flush
./webstack redis cli PING
./webstack memcached stats

# Logs
./webstack logs

# PHP
./php/bin/php -v
./php/bin/php -m

# MySQL
./mysql/bin/mysql --socket=./tmp/mysql.sock -u root

# Backup
./scripts/backup.sh
```

</details>

## 18.3 File Locations

| What | Where |
|------|-------|
| Web root | `www/` |
| Nginx config | `nginx/conf/nginx.conf` |
| PHP config | `php/etc/php.ini` |
| MySQL config | `mysql/my.cnf` |
| Redis config | `redis/redis.conf` |
| Logs | `logs/`, `nginx/logs/`, `php/var/log/` |
| Backups | `backups/` |
| CA certs | `deps/ssl/certs/cacert.pem` |

---

**WebStack Portable Web Server v2.0**

*A fully self-contained web development environment with Nginx, PHP 8.3, Node.js, MySQL, Redis, Memcached, RTMP streaming, and Cloudflare tunnel support.*


