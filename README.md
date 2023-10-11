# DESIGN

# game account generation

## working flow

### enroll

client -> manager(calculate address, create, mint)

### withdraw:

client -> backend -> erc20 wrapper -> mint

### deposit:

client -> erc20 wrapper -> agg(approval/burn) -> emit event

## account management contract

+ call the factory to create account contract;
+ call 721 mint for the account;

## account generator factory contract

## account contract

+ generate a 4337 contract for each enrolled user
+ verify signature

## erc721 contract

+ mint a nft for each user and mark the contract account as the owner

## erc1155 contract

+ including game stuff
+ verify authority when mint and burn

## erc20 contract

+ verify authority when mint and burn

## erc20 wrapper

+ erc20 deposit
+ erc20 stacking
+ erc20 withdraw

# road map

+ deploy bundler
+ deploy paymaster, signer aggregator
+ erc20, erc1155 transaction using 4337
+ account contract
+ account factory
+ erc20 wrapper
+ account management contract
+ stacking contract

# self introduction

my name is wang yuan. I graduated from Shang hai Jiao tong university and got master degree of automatic in 2018. I
joined the hundsun company which is a top financial technology company in China. I worked on fund marketing backend and
user behavior analysis for 2 years, before I switch to blockchain department in 2020. we worked on our company's
consortium blockchain there based on golang (referenced from ethereum and other blockchain, support both evm and jvm,
concurrency execution of transaction). I was responsible for p2p, blockchain, rpc and sdk part. In 2022, I joined
Bitmart which is a medium size exchange invited by my ex-coworker. We do research on cosmos to build its own public
chain for the exchange for a few months, but due to the dump of the cryptocurrency market, the company ceased that
project. We were switched to public chain department and worked on docking public chains to our trading system, handling
stuff like block syncing, trigger transactions. I joined yongcheng in october last year. We build blockchain for nft
exchanges, we use open sourced consortium chain, adding peripheral components especially for nft transfer. After that we
got down to a mma nft game. The battle part of the game is referenced from clash of clay while the elements in game
based on nft. I handle the battle algorithm which based on a star route searching algorithm and the backend contracts.
unfortunately, the game project was stopped three months ago, and We worked on a nft market analysis website after that.
I left the company in september since the task was against my position. I have been looking at erc4337 these days and
trying to optimize the previous game contracts through the protocol.
