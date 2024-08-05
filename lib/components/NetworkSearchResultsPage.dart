import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3_wallet/providers/wallet_provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3_wallet/utils/get_balances.dart';
import 'dart:convert';
import 'package:web3_wallet/components/add_network.dart';

class NetworkSearchResultsPage extends StatefulWidget {
  final String searchTerm; // Include this parameter in the widget

  const NetworkSearchResultsPage({Key? key, required this.searchTerm})
      : super(key: key);

  @override
  _NetworkSearchResultsPageState createState() =>
      _NetworkSearchResultsPageState();
}

class _NetworkSearchResultsPageState extends State<NetworkSearchResultsPage> {
  String walletAddress = '';
  String balance = '';
  String pvKey = '';

  List networkSearchs = [
    {'name': "linea sepolia", 'id': "LINEA_SEPOLIA"},
    {'name': "moonbase", 'id': "MOONBASE"},
    {'name': "moonriver", 'id': "MOONRIVER"},
    {'name': "linea", 'id': "LINEA"},
    {'name': "polygon amoy", 'id': "POLYGON_AMOY"},
    {'name': "holesky", 'id': "HOLESKY"},
    {'name': "optimism", 'id': "OPTIMISM"},
    {'name': "base sepolia", 'id': "BASE_SEPOLIA"},
    {'name': "base", 'id': "BASE"},
    {'name': "gnosis testnet", 'id': "GNOSIS_TESTNET"},
    {'name': "chiliz testnet", 'id': "CHILIZ_TESTNET"},
    {'name': "arbitrum", 'id': "ARBITRUM"},
    {'name': "cronos", 'id': "CRONOS"},
    {'name': "palm", 'id': "PALM"},
    {'name': "avalanche", 'id': "AVALANCHE"},
    {'name': "fantom", 'id': "FANTOM"},
    {'name': "sepolia", 'id': "SEPOLIA"}
  ];

  final Map<String, String> networks = {
    "linea sepolia": "LINEA_SEPOLIA",
    "moonbase": "MOONBASE",
    "moonriver": "MOONRIVER",
    "linea": "LINEA",
    "polygon amoy": "POLYGON_AMOY",
    "holesky": "HOLESKY",
    "optimism": "OPTIMISM",
    "base sepolia": "BASE_SEPOLIA",
    "base": "BASE",
    "gnosis testnet": "GNOSIS_TESTNET",
    "chiliz testnet": "CHILIZ_TESTNET",
    "arbitrum": "ARBITRUM",
    "cronos": "CRONOS",
    "palm": "PALM",
    "avalanche": "AVALANCHE",
    "fantom": "FANTOM",
    "sepolia": "SEPOLIA",
    "polygon": "POLYGON",
    "bsc": "BSC",
    "bsc testnet": "BSC_TESTNET",
    "gnosis": "GNOSIS",
    "moonbeam": "MOONBEAM",
  };

  String selectedNetwork = 'linea sepolia'; // Default network
  TextEditingController _searchController = TextEditingController();

  Map<String, String> networkBalances = {}; // Store balances for each network

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
      setState(() {
        walletAddress = address.hex;
        pvKey = privateKey;
      });

      for (String networkKey in networks.keys) {
        String response = await getBalances(address.hex, networkKey);
        dynamic data = json.decode(response);
        String newBalance = data['balance'] ?? '0';

        // Transform balance from wei to ether
        EtherAmount latestBalance =
            EtherAmount.fromBigInt(EtherUnit.wei, BigInt.parse(newBalance));
        String latestBalanceInEther =
            latestBalance.getValueInUnit(EtherUnit.ether).toString();

        setState(() {
          networkBalances[networkKey] = latestBalanceInEther;
        });
      }
    }
  }

  void updateNetwork(String? newNetwork) {
    setState(() {
      selectedNetwork = newNetwork!;
      loadWalletData(); // Reload wallet data for the new network
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('privateKey');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNetworkPage(privateKey: pvKey),
                ),
                (route) => false,
              );
            },
            icon: Icon(Icons.add_circle_outline),
          ),
        ],
        title: const Text('Networks'),
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
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Perform search action here if needed
                    });
                  },
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: networks.length,
                    itemBuilder: (context, index) {
                      String networkKey = networks.keys.elementAt(index);
                      String networkLabel = networks[networkKey]!;
                      String balance = networkBalances[networkKey] ?? '0';
                      print(networkLabel);

                      return ListTile(
                        title: Text(networkLabel),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          setState(() {
                            selectedNetwork = networkKey;
                          });
                          loadWalletData(); // Reload data for the selected network
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
