import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iraqi_license_plate/iraqi_license_plate.dart';

void main() => runApp(const ExampleApp());

const _text = {
  'en': {
    'plate': 'Plate',
    'gallery': 'Gallery',
    'parse': 'Parse',
    'hint': 'Drag it, flick it, double tap to flip, long press to reset',
    'format': 'Blank',
    'category': 'Category',
    'governorate': 'Governorate',
    'letter': 'Letter',
    'serial': 'Serial',
    'random': 'Random plate',
    'galleryHint': 'Every style the package ships. Tap one to see it in 3D.',
    'parseHint':
        'Type a plate the way your users or your API would. Arabic digits work too.',
    'input': 'Plate number',
    'invalid': 'Not a plate yet',
    'car': 'Car',
    'long': 'European',
    'moto': 'Motorcycle',
    'legacy': 'Legacy',
  },
  'ar': {
    'plate': 'اللوحة',
    'gallery': 'المعرض',
    'parse': 'قراءة',
    'hint': 'اسحبها، ارمِها، انقر مرتين لقلبها، اضغط مطولاً لإرجاعها',
    'format': 'نوع اللوحة',
    'category': 'الفئة',
    'governorate': 'المحافظة',
    'letter': 'الحرف',
    'serial': 'الرقم',
    'random': 'لوحة عشوائية',
    'galleryHint':
        'كل الأنماط في الحزمة. انقر على واحدة لتراها ثلاثية الأبعاد.',
    'parseHint':
        'اكتب اللوحة كما يكتبها المستخدم أو يرسلها الـ API. الأرقام العربية تعمل أيضاً.',
    'input': 'رقم اللوحة',
    'invalid': 'ليست لوحة بعد',
    'car': 'سيارة',
    'long': 'أوروبية',
    'moto': 'دراجة',
    'legacy': 'قديمة',
  },
};

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  var locale = const Locale('en');
  var tab = 0;
  var plate = IraqiPlate.reference;

  void show(IraqiPlate p) => setState(() {
    plate = p;
    tab = 0;
  });

  @override
  Widget build(BuildContext context) {
    final t = _text[locale.languageCode]!;
    final arabic = locale.languageCode == 'ar';
    return MaterialApp(
      title: 'iraqi_license_plate',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF1B7F44),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      builder:
          (context, child) => DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.65),
                radius: 1.3,
                colors: [Color(0xFF1A2530), Color(0xFF07090D)],
              ),
            ),
            child: child,
          ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'iraqi_license_plate',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                'by Mohammad Othman · Abojawdat',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed:
                  () => setState(() => locale = Locale(arabic ? 'en' : 'ar')),
              child: Text(arabic ? 'EN' : 'عربي'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: switch (tab) {
            0 => Showcase(
              plate: plate,
              t: t,
              arabic: arabic,
              onChanged: (p) => setState(() => plate = p),
            ),
            1 => Gallery(t: t, arabic: arabic, onPick: show),
            _ => ParsePage(t: t, onShow: show),
          },
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.black26,
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.view_in_ar),
              label: t['plate']!,
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view),
              label: t['gallery']!,
            ),
            NavigationDestination(
              icon: const Icon(Icons.keyboard),
              label: t['parse']!,
            ),
          ],
        ),
      ),
    );
  }
}

double plateWidth(BuildContext context) =>
    math.min(MediaQuery.sizeOf(context).width - 80, 440);

class Showcase extends StatelessWidget {
  const Showcase({
    required this.plate,
    required this.t,
    required this.arabic,
    required this.onChanged,
    super.key,
  });

  final IraqiPlate plate;
  final Map<String, String> t;
  final bool arabic;
  final ValueChanged<IraqiPlate> onChanged;

  static final _random = math.Random();

  IraqiPlate random() => plate.copyWith(
    governorate:
        IraqGovernorate.values[_random.nextInt(IraqGovernorate.values.length)],
    letter:
        PlateSeries.values[_random.nextInt(PlateSeries.values.length)].latin,
    serial: '${10000 + _random.nextInt(89999)}',
    category:
        PlateCategory.values[_random.nextInt(PlateCategory.values.length)],
  );

  Widget section(String title, Widget child) => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final formats = {
      PlateFormat.modernShort: t['car']!,
      PlateFormat.modernLong: t['long']!,
      PlateFormat.motorcycle: t['moto']!,
      PlateFormat.legacy: t['legacy']!,
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Center(
          child: PlateViewer3D(
            key: ValueKey(plate.format),
            plate: plate,
            width: plateWidth(context),
          ),
        ),
        Text(
          plate.formatted,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          [
            if (plate.governorate != null)
              arabic
                  ? plate.governorate!.arabicName
                  : plate.governorate!.englishName,
            arabic ? plate.category.arabicLabel : plate.category.englishLabel,
            plate.bandText,
          ].join(' · '),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 6),
        Text(
          t['hint']!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Center(
          child: FilledButton.tonalIcon(
            onPressed: () => onChanged(random()),
            icon: const Icon(Icons.casino_outlined),
            label: Text(t['random']!),
          ),
        ),
        section(
          t['format']!,
          Center(
            child: SegmentedButton<PlateFormat>(
              showSelectedIcon: false,
              segments: [
                for (final MapEntry(:key, :value) in formats.entries)
                  ButtonSegment(value: key, label: Text(value)),
              ],
              selected: {plate.format},
              onSelectionChanged:
                  (s) => onChanged(plate.copyWith(format: s.first)),
            ),
          ),
        ),
        section(
          t['category']!,
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in PlateCategory.values)
                ChoiceChip(
                  avatar: Container(
                    decoration: BoxDecoration(
                      color: c.defaultPalette.bandColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38),
                    ),
                  ),
                  label: Text(arabic ? c.arabicLabel : c.englishLabel),
                  selected: c == plate.category,
                  onSelected: (_) => onChanged(plate.copyWith(category: c)),
                ),
            ],
          ),
        ),
        section(
          '${t['governorate']!} · ${t['letter']!} · ${t['serial']!}',
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              DropdownMenu<IraqGovernorate>(
                width: 230,
                initialSelection: plate.governorate,
                label: Text(t['governorate']!),
                onSelected: (g) => onChanged(plate.copyWith(governorate: g)),
                dropdownMenuEntries: [
                  for (final g in IraqGovernorate.values)
                    DropdownMenuEntry(
                      value: g,
                      label:
                          '${g.codeText}  ${arabic ? g.arabicName : g.englishName}',
                    ),
                ],
              ),
              DropdownMenu<String>(
                width: 120,
                initialSelection: plate.letter,
                label: Text(t['letter']!),
                onSelected: (l) => onChanged(plate.copyWith(letter: l)),
                dropdownMenuEntries: [
                  for (final s in PlateSeries.values)
                    DropdownMenuEntry(
                      value: s.latin,
                      label: '${s.latin}  ${s.arabic}',
                    ),
                ],
              ),
              SizedBox(
                width: 150,
                child: TextFormField(
                  key: ValueKey(plate.serial),
                  initialValue: plate.serial,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: InputDecoration(
                    labelText: t['serial'],
                    border: const OutlineInputBorder(),
                    counterText: '',
                  ),
                  onFieldSubmitted: (v) => onChanged(plate.copyWith(serial: v)),
                  onChanged: (v) {
                    if (v.isNotEmpty) onChanged(plate.copyWith(serial: v));
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Gallery extends StatelessWidget {
  const Gallery({
    required this.t,
    required this.arabic,
    required this.onPick,
    super.key,
  });

  final Map<String, String> t;
  final bool arabic;
  final ValueChanged<IraqiPlate> onPick;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          t['galleryHint']!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final style in IraqiPlateStyles.all)
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onPick(style.applyTo(IraqiPlate.reference)),
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 110,
                        child: Center(
                          child: IraqiLicensePlate(
                            plate: style.applyTo(IraqiPlate.reference),
                            palette: style.palette,
                            width:
                                style.format == PlateFormat.motorcycle
                                    ? 130
                                    : 200,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        arabic ? style.nameArabic : style.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class ParsePage extends StatefulWidget {
  const ParsePage({required this.t, required this.onShow, super.key});

  final Map<String, String> t;
  final ValueChanged<IraqiPlate> onShow;

  @override
  State<ParsePage> createState() => _ParsePageState();
}

class _ParsePageState extends State<ParsePage> {
  final controller = TextEditingController(text: '11 A 70634');

  static const samples = [
    '11 A 70634',
    '١٤ ب ٤٨٢١',
    '22-B-1234',
    '12456 ز',
    '27c55102',
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plate = IraqiPlate.tryParse(controller.text);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          widget.t['parseHint']!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: 360,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, letterSpacing: 1.5),
              decoration: InputDecoration(
                labelText: widget.t['input'],
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in samples)
              ActionChip(
                label: Text(s),
                onPressed: () => setState(() => controller.text = s),
              ),
          ],
        ),
        const SizedBox(height: 28),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child:
              plate == null
                  ? Text(
                    widget.t['invalid']!,
                    key: const ValueKey('none'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white38, fontSize: 16),
                  )
                  : Column(
                    key: ValueKey(plate),
                    children: [
                      InkWell(
                        onTap: () => widget.onShow(plate),
                        child: IraqiLicensePlate(
                          plate: plate,
                          width: math.min(plateWidth(context), 360),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        [
                          plate.formatted,
                          if (plate.governorate != null)
                            plate.governorate!.englishName,
                          plate.category.englishLabel,
                          if (plate.validationError != null)
                            plate.validationError!,
                        ].join(' · '),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }
}
