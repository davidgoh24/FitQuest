import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AvatarBackgroundPickerScreen extends StatefulWidget {
  final String selectedBgPath;
  final String selectedAvatarPath;
  final bool isPremiumUser;
  const AvatarBackgroundPickerScreen({
    Key? key,
    required this.selectedBgPath,
    required this.selectedAvatarPath,
    required this.isPremiumUser,
  }) : super(key: key);
  @override
  State<AvatarBackgroundPickerScreen> createState() =>
      _AvatarBackgroundPickerScreenState();
}

class _AvatarBackgroundPickerScreenState
    extends State<AvatarBackgroundPickerScreen> {
  static const List<String> bgPaths = [
    'assets/background/bg1.jpg',
    'assets/background/bg2.jpg',
    'assets/background/bg3.jpeg',
    'assets/background/bg4.jpg',
    'assets/background/bg5.png',
    'assets/background/bg6.png',
    'assets/background/bg7.png',
    'assets/background/bg8.png',
    'assets/background/bg9.png',
  ];
  late String chosenBg;
  @override
  void initState() {
    super.initState();
    chosenBg = widget.selectedBgPath.isNotEmpty
        ? widget.selectedBgPath
        : bgPaths[0];
  }

  Widget buildAvatarOnBg() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            chosenBg,
            width: 140,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage(widget.selectedAvatarPath),
          radius: 70,
        ),
      ],
    );
  }

  Future<void> _confirmBackground() async {
    if (!widget.isPremiumUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upgrade to premium to set background!')),
      );
      return;
    }
    try {
      final backgroundId = _getBackgroundIdFromPath(chosenBg);
      final apiService = ApiService();
      await apiService.setBackground(backgroundId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Background updated successfully!')),
      );
      Navigator.pop(context, chosenBg);
    } catch (e) {
      print('Failed to update background: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update background')),
      );
    }
  }

  int _getBackgroundIdFromPath(String path) {
    final bgMap = {
      'assets/background/bg1.jpg': 1,
      'assets/background/bg2.jpg': 2,
      'assets/background/bg3.jpeg': 3,
      'assets/background/bg4.jpg': 4,
      'assets/background/bg5.png': 5,
      'assets/background/bg6.png': 6,
      'assets/background/bg7.png': 7,
      'assets/background/bg8.png': 8,
      'assets/background/bg9.png': 9,
    };
    return bgMap[path] ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Background",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          buildAvatarOnBg(),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.13),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                        onPressed: () => Navigator.pop(context),
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Background',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: GridView.builder(
                        itemCount: bgPaths.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 24,
                        ),
                        itemBuilder: (context, index) {
                          final path = bgPaths[index];
                          final isChosen = chosenBg == path;
                          return GestureDetector(
                            onTap: widget.isPremiumUser
                                ? () => setState(() {
                              chosenBg = path;
                            })
                                : null,
                            child: Opacity(
                              opacity: widget.isPremiumUser ? 1.0 : 0.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: isChosen
                                      ? Border.all(
                                      color: colorScheme.secondary, width: 3)
                                      : null,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    path,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        Container(
                                            color:
                                            colorScheme.surfaceVariant),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 60,
                      ),
                      textStyle: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontSize: 18),
                    ),
                    onPressed: _confirmBackground,
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                          color: colorScheme.onPrimary, fontSize: 18),
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