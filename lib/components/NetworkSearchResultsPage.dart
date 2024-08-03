import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3_wallet/providers/wallet_provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3_wallet/utils/get_balances.dart';
import 'dart:convert';
import 'package:web3_wallet/components/add_network.dart';

class NetworkSearchResultsPage extends StatefulWidget {
  final String searchTerm; // Include this parameter in the widget

  const NetworkSearchResultsPage({Key? key, required this.searchTerm}) : super(key: key);

  @override
  _NetworkSearchResultsPageState createState() => _NetworkSearchResultsPageState();
}

class _NetworkSearchResultsPageState extends State<NetworkSearchResultsPage> {
  String walletAddress = '';
  String balance = '';
  String pvKey = '';
  
  String selectedNetwork = 'Ethereum'; // Default network
  final List<String> networks = ['Ethereum', 'Bitcoin', 'Solana'];
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
      setState(() {
        walletAddress = address.hex;
        pvKey = privateKey;
      });

      String response = await getBalances(address.hex, selectedNetwork.toLowerCase());
      dynamic data = json.decode(response);
      String newBalance = data['balance'] ?? '0';

      // Transform balance from wei to ether
      EtherAmount latestBalance = EtherAmount.fromBigInt(EtherUnit.wei, BigInt.parse(newBalance));
      String latestBalanceInEther = latestBalance.getValueInUnit(EtherUnit.ether).toString();

      setState(() {
        balance = latestBalanceInEther;
      });
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
                      walletAddress = value;
                    });
                    // Perform search action here if needed
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
                              value: selectedNetwork,
                              onChanged: updateNetwork,
                              items: networks.map((String network) {
                                return DropdownMenuItem<String>(
                                  value: network,
                                  child: Text(network),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
