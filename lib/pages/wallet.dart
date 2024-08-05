import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3_wallet/components/search_delegate.dart';
import 'package:web3_wallet/providers/wallet_provider.dart';
import 'package:web3_wallet/pages/create_or_import.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3_wallet/utils/get_balances.dart';
import 'package:web3_wallet/components/nft_balances.dart';
import 'package:web3_wallet/components/send_tokens.dart';
import 'package:web3_wallet/components/NetworkSearchResultsPage.dart';
import 'package:web3_wallet/components/setting.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key, required this.wallets}) : super(key: key);

  final List wallets;

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String walletAddress = '';
  String balance = '';
  String pvKey = '';
  String selectedNetwork = 'Sepolia'; // Default network
  final List<String> networks = [
    'Mainnet',
    'Ropsten',
    'Kovan',
    'Rinkeby',
    'Goerli',
    'Sepolia'
  ];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadWalletData();
  }

  Future<void> loadWalletData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('privateKey');
    if (privateKey != null) {
      final walletProvider = WalletProvider();
      await walletProvider.loadPrivateKey();
      EthereumAddress address = await walletProvider.getPublicKey(privateKey);
      print(address.hex);
      // 0x19bdb465bca107d9a81d23380db7adef1a995c5e
      // 0x19bdb465bca107d9a81d23380db7adef1a995c5e
      setState(() {
        walletAddress = address.hex;
        pvKey = privateKey;
      });
      print(pvKey);
      String response =
          await getBalances(address.hex, selectedNetwork.toLowerCase());
      dynamic data = json.decode(response);
      String newBalance = data['balance'] ?? '0';

      // Transform balance from wei to ether
      EtherAmount latestBalance =
          EtherAmount.fromBigInt(EtherUnit.wei, BigInt.parse(newBalance));
      String latestBalanceInEther =
          latestBalance.getValueInUnit(EtherUnit.ether).toString();

      setState(() {
        balance = latestBalanceInEther;
      });
    }
  }

  void _performSearch() {
    final searchTerm = _searchController.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NetworkSearchResultsPage(searchTerm: searchTerm),
      ),
    );
  }

  void updateNetwork(String? newNetwork) {
    setState(() {
      selectedNetwork = newNetwork!;
      loadWalletData(); // Reload wallet data for the new network
    });
  }

  List<Map<String, String>> networkSearchs = [
    {'name': "linea sepolia", 'id': "LINEA_SEPOLIA","image":"assets/images/alphachain.png"},
    {'name': "moonbase", 'id': "MOONBASE","image":"assets/images/alphachain.png"},
    {'name': "moonriver", 'id': "MOONRIVER","image":"assets/images/alphachain.png"},
    {'name': "linea", 'id': "LINEA","image":"assets/images/alphachain.png"},
    {'name': "polygon amoy", 'id': "POLYGON_AMOY","image":"assets/images/alphachain.png"},
    {'name': "holesky", 'id': "HOLESKY","image":"assets/images/alphachain.png"},
    {'name': "optimism", 'id': "OPTIMISM","image":"assets/images/alphachain.png"},
    {'name': "base sepolia", 'id': "BASE_SEPOLIA","image":"assets/images/alphachain.png"},
    {'name': "base", 'id': "BASE","image":"assets/images/alphachain.png"},
    {'name': "gnosis testnet", 'id': "GNOSIS_TESTNET","image":"assets/images/alphachain.png"},
    {'name': "chiliz testnet", 'id': "CHILIZ_TESTNET","image":"assets/images/alphachain.png"},
    {'name': "arbitrum", 'id': "ARBITRUM","image":"assets/images/alphachain.png"},
    {'name': "cronos", 'id': "CRONOS","image":"assets/images/alphachain.png"},
    {'name': "palm", 'id': "PALM","image":"assets/images/alphachain.png"},
    {'name': "avalanche", 'id': "AVALANCHE","image":"assets/images/alphachain.png"},
    {'name': "fantom", 'id': "FANTOM","image":"assets/images/alphachain.png"},
    {'name': "sepolia", 'id': "SEPOLIA", "image":"assets/images/alphachain.png"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingPage(privateKey: pvKey),
              ),
            );
          },
          icon: Icon(Icons.settings),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('privateKey');
                // ignore: use_build_context_synchronously
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateOrImportPage(),
                  ),
                  (route) => false,
                );
              },
              icon: Icon(Icons.logout))
        ],
        title: const Text('Alphachain Wallet'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for Networks',
                    prefixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed:
                          _performSearch, // Trigger the search on icon press
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onTap: () {
                    // _performSearch(); // Navigate to results page on TextField tap
                    showSearch(
                        context: context,
                        delegate: CustomSearchDelegate(networkSearchs));
                  },
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            DropdownButton<String>(
                              underline: const SizedBox.shrink(),
                              value: selectedNetwork,
                              onChanged: updateNetwork,
                              items: networks.map((String network) {
                                return DropdownMenuItem<String>(
                                  value: network,
                                  child: Text(network),
                                );
                              }).toList(),
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: walletAddress));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Address copied to clipboard')),
                                );
                              },
                              icon: Icon(Icons.copy),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  balance,
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'sendButton',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SendTokensPage(privateKey: pvKey),
                              ),
                            );
                          },
                          child: const Icon(Icons.send),
                        ),
                        const SizedBox(height: 8.0),
                        const Text('Send'),
                      ],
                    ),
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'receiveButton',
                          onPressed: () {
                            loadWalletData(); // Refresh the wallet data
                          },
                          child: const Icon(Icons.replay_outlined),
                        ),
                        const SizedBox(height: 8.0),
                        const Text('Receive'),
                      ],
                    ),
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'scanButton',
                          onPressed: () {
                            loadWalletData(); // Refresh the wallet data
                          },
                          child: const Icon(Icons.qr_code_scanner),
                        ),
                        const SizedBox(height: 8.0),
                        const Text('Scan'),
                      ],
                    ),
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'historyButton',
                          onPressed: () {
                            loadWalletData(); // Refresh the wallet data
                          },
                          child: const Icon(Icons.history_edu),
                        ),
                        const SizedBox(height: 8.0),
                        const Text('History'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.blue,
                    tabs: [
                      Tab(text: 'Assets'),
                      Tab(text: 'NFTs'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Assets Tab
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Card(
                                margin: const EdgeInsets.all(16.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$selectedNetwork ETH',
                                        style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        balance,
                                        style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        // NFTs Tab
                        SingleChildScrollView(
                            child: NFTListPage(
                                address: walletAddress,
                                chain: selectedNetwork.toLowerCase())),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
