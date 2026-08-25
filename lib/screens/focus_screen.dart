import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/notification_service.dart';

class FocusScreen extends StatefulWidget {
  final VoidCallback onSessionFinished;
  const FocusScreen({super.key, required this.onSessionFinished});
  @override State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int selectedMinutes = 25;
  int remainingSeconds = 25 * 60;
  bool isCustomDuration = false;
  String track = 'Study';
  Timer? _timer;
  Timer? _alarmAudioLoop;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool get isRunning => _timer?.isActive ?? false;

  @override
  void dispose() {
    _timer?.cancel();
    _alarmAudioLoop?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void selectDuration(int minutes, {bool isCustom = false}) {
    _timer?.cancel();
    _alarmAudioLoop?.cancel();
    _audioPlayer.stop();
    setState(() {
      selectedMinutes = minutes;
      remainingSeconds = minutes * 60;
      isCustomDuration = isCustom;
    });
  }

  void _showCustomDurationDialog() {
    final controller = TextEditingController(text: selectedMinutes.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.timer_outlined, color: Color(0xFF4F46E5)),
            SizedBox(width: 10),
            Text('Custom Focus Timer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF172033))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter custom duration in minutes (1 – 300):', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF172033)),
              decoration: InputDecoration(
                suffixText: 'min',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0 && val <= 300) {
                selectDuration(val, isCustom: true);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Set Timer'),
          ),
        ],
      ),
    );
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() => remainingSeconds = 0);
    widget.onSessionFinished();
    _triggerAlarm();
  }

  void _triggerAlarm() async {
    // 1. Play real alarm chime audio asset
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/alarm_chime.wav'));
    } catch (e) {
      // Fallback
    }

    // 2. Haptic & System Sound feedback
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.vibrate();
    HapticFeedback.heavyImpact();

    // 3. High-importance notification with sound and vibration
    await NotificationService.showTimerAlarmNotification(
      title: '⏰ Focus Session Finished!',
      body: 'Your $selectedMinutes min $track focus block is complete. Great work!',
    );

    if (!mounted) return;

    // 4. Display interactive Alarm Completion Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.alarm_on_rounded, size: 44, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Focus Block Completed! 🎯',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF172033)),
            ),
            const SizedBox(height: 8),
            Text(
              'You successfully focused on "$track" for $selectedMinutes minutes. Take a well-earned break!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  _audioPlayer.stop();
                  _alarmAudioLoop?.cancel();
                  Navigator.pop(ctx);
                  selectDuration(selectedMinutes, isCustom: isCustomDuration);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Dismiss Alarm & Reset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleTimer() {
    if (isRunning) {
      _timer?.cancel();
      setState(() {});
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 1) {
        _onTimerComplete();
      } else {
        setState(() => remainingSeconds--);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    final totalSecs = selectedMinutes * 60;
    final progress = totalSecs > 0 ? (remainingSeconds / totalSecs).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Focus Timer', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('One thing. No noise.', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF172033))),
              const SizedBox(height: 6),
              const Text('Choose a block and protect it.', style: TextStyle(color: Color(0xFF64748B))),
              const Spacer(),
              Center(
                child: SizedBox(
                  width: 245,
                  height: 245,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          strokeCap: StrokeCap.round,
                          color: const Color(0xFF4F46E5),
                          backgroundColor: const Color(0xFFE0E7FF),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$minutes:$seconds', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Color(0xFF172033))),
                          Text(isRunning ? 'FOCUSING' : 'READY', style: const TextStyle(letterSpacing: 1.5, fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Text('What are you working on?', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF172033))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: track,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                items: ['Study', 'Project', 'Coursework', 'Placement prep']
                    .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                    .toList(),
                onChanged: isRunning ? null : (value) { if (value != null) setState(() => track = value); },
              ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...[15, 25, 45, 60].map((mins) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('$mins min'),
                            selected: !isCustomDuration && selectedMinutes == mins,
                            selectedColor: const Color(0xFFE0E7FF),
                            onSelected: isRunning ? null : (_) => selectDuration(mins),
                          ),
                        )),
                    ActionChip(
                      avatar: const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF4F46E5)),
                      label: Text(isCustomDuration ? 'Custom ($selectedMinutes min)' : 'Custom ⏱️'),
                      backgroundColor: isCustomDuration ? const Color(0xFFE0E7FF) : const Color(0xFFF1F5F9),
                      side: BorderSide.none,
                      onPressed: isRunning ? null : _showCustomDurationDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: toggleTimer,
                  icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(isRunning ? 'Pause focus' : 'Start $selectedMinutes min focus'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
