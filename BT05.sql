
/*
1. Kịch bản rủi ro (input sai)
Người dùng tạo 2 ví cho 1 tài khoản
Nạp/rút với số tiền âm hoặc = 0
Giao dịch không có trạng thái hoặc trạng thái sai
Số dư ví bị âm tiền
Giao dịch không gắn với ví hợp lệ
*/
create table users (
    user_id int auto_increment primary key,
    fullname varchar(100) not null
);

create table wallets (
    wallet_id int auto_increment primary key,
    user_id int not null unique,
    balance decimal(12,2) not null default 0 check (balance >= 0),

    foreign key (user_id)
    references users(user_id)
);

create table transactions (
    transaction_id int auto_increment primary key,
    wallet_id int not null,
    type varchar(20) not null,
    amount decimal(12,2) not null check (amount > 0),
    status varchar(20) not null default 'pending',
    created_at datetime default current_timestamp,

    foreign key (wallet_id) references wallets(wallet_id)
);