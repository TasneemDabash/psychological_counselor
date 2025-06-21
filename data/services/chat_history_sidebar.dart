class ChatHistorySidebar extends StatelessWidget {
  final void Function(String sessionId) onSessionSelected;

  const ChatHistorySidebar({Key? key, required this.onSessionSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_sessions')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final sessions = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "📂 ההיסטוריה שלי",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(),

            /// ❗ הפתרון הקריטי: עוטפים את ה־ListView ב־Expanded
            Expanded(
              child: ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return ListTile(
                    title: Text(
                      session['title'] ?? 'שיחה',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      onSessionSelected(session.id);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
