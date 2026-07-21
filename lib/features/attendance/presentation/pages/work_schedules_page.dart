import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/work_schedule_model.dart';
import '../providers/work_schedules_provider.dart';
import '../../../../../core/utils/time_formatters.dart';

class WorkSchedulesPage extends ConsumerStatefulWidget {
  const WorkSchedulesPage({super.key});

  @override
  ConsumerState<WorkSchedulesPage> createState() => _WorkSchedulesPageState();
}

class _WorkSchedulesPageState extends ConsumerState<WorkSchedulesPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(workSchedulesProvider.notifier).loadSchedules();
    });
  }
  String _formatTimeOfDayForDb(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:00';
  }
  Future<void> _confirmDeleteSchedule(WorkScheduleModel schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'حذف جدول الدوام',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: Text(
            schedule.isDefault
                ? 'هذا جدول دوام افتراضي ولا يمكن حذفه. اجعل جدولًا آخر افتراضيًا أولاً.'
                : 'هل أنت متأكد من حذف جدول الدوام "${schedule.name}"؟\n\nلا يمكن التراجع عن هذه العملية.',
            style: const TextStyle(
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: schedule.isDefault
                  ? null
                  : () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('حذف نهائي'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final success = await ref
        .read(workSchedulesProvider.notifier)
        .deleteSchedule(schedule.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف جدول الدوام بنجاح'),
          backgroundColor: Color(0xFF0F766E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error = ref.read(workSchedulesProvider).error;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'تعذر حذف جدول الدوام'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  TimeOfDay _parseTimeOfDay(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> _openScheduleForm([WorkScheduleModel? schedule]) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ScheduleFormSheet(
          schedule: schedule,
          parseTimeOfDay: _parseTimeOfDay,
          formatTimeOfDayForDb: _formatTimeOfDayForDb,
          onSubmit: ({
            required String name,
            required String startTime,
            required String endTime,
            required int graceMinutes,
            required List<int> workDays,
            required bool isDefault,
            required String scheduleType,
            required int requiredMinutes,
            required bool allowCheckInAfterEndTime,
          }) async {
            final notifier = ref.read(workSchedulesProvider.notifier);

            final success = schedule == null
                ? await notifier.createSchedule(
              name: name,
              startTime: startTime,
              endTime: endTime,
              graceMinutes: graceMinutes,
              workDays: workDays,
              isDefault: isDefault,
              scheduleType: scheduleType,
              requiredMinutes: requiredMinutes,
              allowCheckInAfterEndTime: allowCheckInAfterEndTime,
            )
                : await notifier.updateSchedule(
              id: schedule.id,
              name: name,
              startTime: startTime,
              endTime: endTime,
              graceMinutes: graceMinutes,
              workDays: workDays,
              isDefault: isDefault,
              scheduleType: scheduleType,
              requiredMinutes: requiredMinutes,
              allowCheckInAfterEndTime: allowCheckInAfterEndTime,
            );

            if (!context.mounted) return;

            if (success) {
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    schedule == null
                        ? 'تم إنشاء جدول الدوام بنجاح'
                        : 'تم تعديل جدول الدوام بنجاح',
                  ),
                  backgroundColor: const Color(0xFF0F766E),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      },
    );
  }
  String _scheduleTypeText(String type) {
    switch (type) {
      case 'fixed':
        return 'دوام ثابت';
      case 'hourly':
        return 'دوام ساعات';
      default:
        return type;
    }
  }

  String _workDaysText(List<int> days) {
    const dayNames = {
      1: 'الإثنين',
      2: 'الثلاثاء',
      3: 'الأربعاء',
      4: 'الخميس',
      5: 'الجمعة',
      6: 'السبت',
      7: 'الأحد',
    };

    if (days.isEmpty) return '--';

    return days.map((day) => dayNames[day] ?? day.toString()).join('، ');
  }

  String _requiredHoursText(int minutes) {
    if (minutes <= 0) return '--';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (mins == 0) return '$hours ساعات';
    return '$hours ساعات و $mins دقيقة';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workSchedulesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'إعدادات الدوام',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () {
              ref.read(workSchedulesProvider.notifier).loadSchedules();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'إضافة جدول دوام',
            onPressed: () => _openScheduleForm(),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }

          if (state.schedules.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(workSchedulesProvider.notifier).loadSchedules();
              },
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                  Icon(
                    Icons.work_history_outlined,
                    size: 76,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'لا توجد جداول دوام حالياً',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(workSchedulesProvider.notifier).loadSchedules();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.schedules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final schedule = state.schedules[index];

                return _WorkScheduleCard(
                  schedule: schedule,
                  scheduleTypeText: _scheduleTypeText,
                  workDaysText: _workDaysText,
                  requiredHoursText: _requiredHoursText,
                  onTap: () => _openScheduleForm(schedule),
                  onDelete: () => _confirmDeleteSchedule(schedule),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _WorkScheduleCard extends StatelessWidget {
  const _WorkScheduleCard({
    required this.schedule,
    required this.scheduleTypeText,
    required this.workDaysText,
    required this.requiredHoursText,
    required this.onTap,
    required this.onDelete,
  });
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final WorkScheduleModel schedule;
  final String Function(String) scheduleTypeText;
  final String Function(List<int>) workDaysText;
  final String Function(int) requiredHoursText;

  @override
  Widget build(BuildContext context) {
    final isFixed = schedule.scheduleType == 'fixed';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFECFDF5),
                    child: Icon(
                      isFixed
                          ? Icons.schedule_rounded
                          : Icons.hourglass_bottom_rounded,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      schedule.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  if (schedule.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'افتراضي',
                        style: TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  IconButton(
                    tooltip: 'حذف جدول الدوام',
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),


              _InfoRow(
                icon: Icons.category_outlined,
                label: 'نوع الدوام',
                value: scheduleTypeText(schedule.scheduleType),
              ),
              const SizedBox(height: 10),
              if (isFixed) ...[
                _InfoRow(
                  icon: Icons.login_rounded,
                  label: 'بداية الدوام',
                  value: formatTime12(schedule.startTime),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.logout_rounded,
                  label: 'نهاية الدوام',
                  value: formatTime12(schedule.endTime),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.timer_outlined,
                  label: 'فترة السماحية',
                  value: '${schedule.graceMinutes} دقيقة',
                ),
              ] else ...[
                _InfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'الساعات المطلوبة',
                  value: requiredHoursText(schedule.requiredMinutes),
                ),
              ],
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.calendar_month_outlined,
                label: 'أيام العمل',
                value: workDaysText(schedule.workDays),
              ),
              if (isFixed) ...[
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.policy_outlined,
                  label: 'الحضور بعد نهاية الدوام',
                  value: schedule.allowCheckInAfterEndTime ? 'مسموح' : 'غير مسموح',
                ),
              ] else ...[
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'طريقة الحساب',
                  value: 'يتم احتساب الالتزام حسب إجمالي ساعات العمل فقط',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 19),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleFormSheet extends StatefulWidget {
  const _ScheduleFormSheet({
    required this.schedule,
    required this.parseTimeOfDay,
    required this.formatTimeOfDayForDb,
    required this.onSubmit,
  });

  final WorkScheduleModel? schedule;
  final TimeOfDay Function(String value) parseTimeOfDay;
  final String Function(TimeOfDay time) formatTimeOfDayForDb;

  final Future<void> Function({
  required String name,
  required String startTime,
  required String endTime,
  required int graceMinutes,
  required List<int> workDays,
  required bool isDefault,
  required String scheduleType,
  required int requiredMinutes,
  required bool allowCheckInAfterEndTime,
  }) onSubmit;

  @override
  State<_ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<_ScheduleFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _graceController;
  late final TextEditingController _requiredMinutesController;

  late String _scheduleType;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isDefault;
  late bool _allowCheckInAfterEndTime;
  late List<int> _workDays;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final schedule = widget.schedule;

    _nameController = TextEditingController(text: schedule?.name ?? '');
    _graceController = TextEditingController(
      text: (schedule?.graceMinutes ?? 15).toString(),
    );
    _requiredMinutesController = TextEditingController(
      text: (schedule?.requiredMinutes ?? 480).toString(),
    );

    _scheduleType = schedule?.scheduleType ?? 'fixed';
    _startTime = widget.parseTimeOfDay(schedule?.startTime ?? '08:00:00');
    _endTime = widget.parseTimeOfDay(schedule?.endTime ?? '16:00:00');
    _isDefault = schedule?.isDefault ?? false;
    _allowCheckInAfterEndTime =
        schedule?.allowCheckInAfterEndTime ?? true;
    _workDays = List<int>.from(schedule?.workDays ?? [1, 2, 3, 4, 5]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _graceController.dispose();
    _requiredMinutesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final grace = int.tryParse(_graceController.text.trim()) ?? 0;
    final requiredMinutes =
        int.tryParse(_requiredMinutesController.text.trim()) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اسم جدول الدوام مطلوب')),
      );
      return;
    }

    if (_workDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب اختيار يوم عمل واحد على الأقل')),
      );
      return;
    }

    setState(() => _isSaving = true);

    await widget.onSubmit(
      name: name,
      startTime: widget.formatTimeOfDayForDb(_startTime),
      endTime: widget.formatTimeOfDayForDb(_endTime),
      graceMinutes: grace,
      workDays: _workDays..sort(),
      isDefault: _isDefault,
      scheduleType: _scheduleType,
      requiredMinutes: requiredMinutes,
      allowCheckInAfterEndTime:
      _scheduleType == 'fixed' ? _allowCheckInAfterEndTime : true,
    );

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  String _dayText(int day) {
    const days = {
      1: 'إثنين',
      2: 'ثلاثاء',
      3: 'أربعاء',
      4: 'خميس',
      5: 'جمعة',
      6: 'سبت',
      7: 'أحد',
    };

    return days[day] ?? day.toString();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isFixed = _scheduleType == 'fixed';

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.schedule == null
                    ? 'إضافة جدول دوام'
                    : 'تعديل جدول الدوام',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 18),

              _SheetTextField(
                controller: _nameController,
                label: 'اسم جدول الدوام',
                icon: Icons.badge_outlined,
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نوع الدوام',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),

                    // ✅ دوام ثابت من ساعة إلى ساعة
                    RadioListTile<String>(
                      value: 'fixed',
                      groupValue: _scheduleType,
                      onChanged: (value) {
                        setState(() => _scheduleType = value!);
                      },
                      title: const Text('دوام ثابت من ساعة إلى ساعة'),
                      activeColor: const Color(0xFF0F766E),
                      contentPadding: EdgeInsets.zero,
                    ),

                    // ✅ دوام ساعات فقط
                    RadioListTile<String>(
                      value: 'hourly',
                      groupValue: _scheduleType,
                      onChanged: (value) {
                        setState(() => _scheduleType = value!);
                      },
                      title: const Text('دوام ساعات فقط'),
                      activeColor: const Color(0xFF0F766E),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (isFixed) ...[
                Row(
                  children: [
                    Expanded(
                      child: _SheetPickerTile(
                        icon: Icons.login_rounded,
                        label: 'بداية الدوام',
                        value: formatTimeOfDay12(_startTime),
                        onTap: () {
                          _pickTime(
                            initial: _startTime,
                            onPicked: (v) =>
                                setState(() => _startTime = v),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SheetPickerTile(
                        icon: Icons.logout_rounded,
                        label: 'نهاية الدوام',
                        value: formatTimeOfDay12(_endTime),
                        onTap: () {
                          _pickTime(
                            initial: _endTime,
                            onPicked: (v) =>
                                setState(() => _endTime = v),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SheetTextField(
                  controller: _graceController,
                  label: 'فترة السماحية بالدقائق',
                  icon: Icons.timer_outlined,
                  keyboardType: TextInputType.number,
                ),
              ],

              if (!isFixed) ...[
                _SheetTextField(
                  controller: _requiredMinutesController,
                  label: 'عدد الدقائق المطلوبة يومياً',
                  icon: Icons.hourglass_bottom_rounded,
                  keyboardType: TextInputType.number,
                ),
              ],

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'أيام العمل',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (index) {
                        final day = index + 1;
                        final selected = _workDays.contains(day);

                        return FilterChip(
                          label: Text(_dayText(day)),
                          selected: selected,
                          selectedColor:
                          const Color(0xFF0F766E).withValues(alpha: 0.15),
                          checkmarkColor: const Color(0xFF0F766E),
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                _workDays.add(day);
                              } else {
                                _workDays.remove(day);
                              }
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              SwitchListTile(
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
                title: const Text(
                  'جعله جدول الدوام الافتراضي',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                activeColor: const Color(0xFF0F766E),
              ),

              if (isFixed)
                SwitchListTile(
                  value: _allowCheckInAfterEndTime,
                  onChanged: (value) =>
                      setState(() => _allowCheckInAfterEndTime = value),
                  title: const Text(
                    'السماح بالحضور بعد نهاية الدوام',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'يستخدم فقط في الدوام الثابت لمنع تسجيل الحضور بعد نهاية الدوام الرسمي.',
                  ),
                  activeColor: const Color(0xFF0F766E),
                ),

              const SizedBox(height: 18),

              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.save_rounded),
                  label: const Text('حفظ جدول الدوام'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF94A3B8),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
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

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF0F766E),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _SheetPickerTile extends StatelessWidget {
  const _SheetPickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF0F766E), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}