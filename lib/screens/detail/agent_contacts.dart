import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'agent_detail_screen.dart';

class AgentContactsScreen extends StatefulWidget {
  const AgentContactsScreen({super.key});

  @override
  State<AgentContactsScreen> createState() => _AgentContactsScreenState();
}

class _AgentContactsScreenState extends State<AgentContactsScreen> {
  late Future<List<dynamic>> futureAgents;

  @override
  void initState() {
    super.initState();
    futureAgents = fetchAgents();
  }

  Future<List<dynamic>> fetchAgents() async {
    final response = await http.post(
      Uri.parse('https://online.nks.vn/api/nks/rsagents'),
    );

    final jsonData = json.decode(response.body);
    if (jsonData['success'] == true && jsonData['data'] != null) {
      return jsonData['data'];
    } else {
      throw Exception(jsonData['message'] ?? 'Failed to load agents');
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể thực hiện cuộc gọi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0077bb);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh bạ môi giới',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureAgents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          final agents = snapshot.data!;

          return ListView.builder(
            itemCount: agents.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final agent = agents[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12), // cho hiệu ứng ripple đẹp
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AgentDetailScreen(
                        agentId: agent['id'].toString(),
                        agentName: agent['name'] ?? '',
                        avatarUrl: agent['avatar'] ?? '',
                        postsCount: agent['rsitems'] ?? 0,
                      ),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(agent['avatar'] ?? ''),
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agent['name'] ?? '',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tin đăng: ${agent['rsitems'] ?? 0}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (agent['email'] != null)
                                Text(
                                  agent['email'],
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        if (agent['phone'] != null)
                          IconButton(
                            icon: const Icon(Icons.phone, color: primaryColor),
                            onPressed: () => _callPhone(agent['phone']),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
