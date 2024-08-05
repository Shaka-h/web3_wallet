from flask import Flask, request
from dotenv import load_dotenv
from moralis import evm_api
import json
import os

load_dotenv()

app = Flask(__name__)
api_key = os.getenv("MORALIS_API_KEY")


@app.route("/get_token_balance", methods=["GET"])
def get_tokens():
    chain = request.args.get("chain")
    address = request.args.get("address")

    params = {
        "address": address,
        "chain": chain,
    }
    result = evm_api.balance.get_native_balance(
        api_key=api_key,
        params=params,
    )

    return result

@app.route("/get_wallet_token_balances_price", methods=["GET"])
def get_wallet_token_balances_price():
    chain = request.args.get("chain")
    address = request.args.get("address")

    params = {
        "chain": chain,
        "address": address,
    }
    result = evm_api.wallets.get_wallet_token_balances_price(
        api_key=api_key,
        params=params,
    )

    return result


@app.route("/get_user_nfts", methods=["GET"])
def get_nfts():
    address = request.args.get("address")
    chain = request.args.get("chain")
    params = {
        "address": address,
        "chain": chain,
        "format": "decimal",
        "limit": 100,
        "token_addresses": [],
        "cursor": "",
        "normalizeMetadata": True,
    }

    result = evm_api.nft.get_wallet_nfts(
        api_key=api_key,
        params=params,
    )

    # converting it to json because of unicode characters
    response = json.dumps(result, indent=4)
    print(response)
    return response


@app.route("/get_wallet_history", methods=["GET"])
def get_wallet_history():
    chain = request.args.get("chain")
    order = request.args.get("order")
    address = request.args.get("address")

    params = {
        "address": address,
        "chain": chain,
        "order": order,
    }
    result = evm_api.wallets.get_wallet_history(
        api_key=api_key,
        params=params,
    )

    return result


@app.route("/get_wallet_active_chains", methods=["GET"])
def get_wallet_active_chains():
    address = request.args.get("address")

    params = {
        "address": address,
    }

    result = evm_api.wallets.get_wallet_active_chains(
        api_key=api_key,
        params=params,
    )

    return result

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=True)