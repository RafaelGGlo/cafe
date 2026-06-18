import 'package:flutter/material.dart';

import '../services/backup_scheduler_service.dart';

/// Opens the automatic backup settings modal.
Future<void> showBackupScheduleModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const BackupScheduleModal(),
  );
}

/// Modal that lets the user enable automatic backup and choose the backup time.
class BackupScheduleModal extends StatefulWidget {
  const BackupScheduleModal({super.key});

  @override
  State<BackupScheduleModal> createState() => _BackupScheduleModalState();
}

class _BackupScheduleModalState extends State<BackupScheduleModal> {
  final BackupSchedulerService _schedulerService = BackupSchedulerService();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _schedulerService.isAutomaticBackupEnabled();
    final scheduledTime = await _schedulerService.getScheduledTime();

    if (!mounted) {
      return;
    }

    setState(() {
      _isEnabled = enabled;
      _selectedTime = scheduledTime;
      _isLoading = false;
    });
  }

  Future<void> _changeEnabled(bool enabled) async {
    setState(() {
      _isSaving = true;
      _isEnabled = enabled;
    });

    try {
      await _schedulerService.setAutomaticBackupEnabled(enabled);
      _showMessage(
        enabled ? 'Automatic backup enabled.' : 'Automatic backup disabled.',
      );
    } catch (error) {
      _showMessage('Could not update automatic backup: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _isSaving = true;
      _selectedTime = pickedTime;
    });

    try {
      await _schedulerService.saveScheduledTime(pickedTime);
      _showMessage('Automatic backup time saved.');
    } catch (error) {
      _showMessage('Could not save backup time: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPadding + 24),
        child: _isLoading
            ? const Center(heightFactor: 3, child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Automatic backup',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable daily Google Drive backup'),
                    value: _isEnabled,
                    onChanged: _isSaving ? null : _changeEnabled,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: !_isSaving,
                    title: const Text('Backup time'),
                    subtitle: Text(_selectedTime.format(context)),
                    trailing: const Icon(Icons.schedule),
                    onTap: _pickTime,
                  ),
                ],
              ),
      ),
    );
  }
}
