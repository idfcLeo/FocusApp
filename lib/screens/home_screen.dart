import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_item.dart';
import '../models/habit.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../utils/page_transitions.dart';
import 'food_scanner_screen.dart';
import 'habit_screen.dart';
import 'plans_screen.dart';
import 'fitness_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateToTab;
  final VoidCallback onDataChanged;
  const HomeScreen({super.key, required this.onNavigateToTab, required this.onDataChanged});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskItem> tasks = []; List<HabitItem> habits = []; List<FoodLogItem> foods = [];
  int water = 0, waterGoal = 3000, proteinGoal = 120; bool loading = true;
  static const indigo = Color(0xFF4F46E5);
  @override void initState() { super.initState(); StorageService.changes.addListener(_refreshFromStorage); load(); }
  void _refreshFromStorage() { if (mounted) load(); }
  @override void dispose() { StorageService.changes.removeListener(_refreshFromStorage); super.dispose(); }
  Future<void> load() async {
    final r = await Future.wait([StorageService.loadTasks(), StorageService.loadHabits(), StorageService.loadFoodLogs(), StorageService.loadWaterIntake(), StorageService.loadWaterGoal(), StorageService.loadProteinGoal()]);
    if (!mounted) return; setState(() { tasks=r[0] as List<TaskItem>; habits=r[1] as List<HabitItem>; foods=r[2] as List<FoodLogItem>; water=r[3] as int; waterGoal=r[4] as int; proteinGoal=r[5] as int; loading=false; });
  }
  String day(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  bool today(DateTime? d) => d != null && day(d) == day(DateTime.now());
  bool todayOrPast(DateTime? d) => d == null || day(d) == day(DateTime.now()) || d.isBefore(DateTime.now());
  int get protein => foods.where((f) => today(f.timestamp)).fold(0, (a, f) => a + f.proteinGrams.round());
  int get streak => habits.isEmpty ? 0 : habits.map((h)=>h.streakCount).reduce((a,b)=>a<b?a:b);
  Future<void> logWater(int ml) async {
    final now = DateTime.now();
    final nextFoods = [...foods, FoodLogItem(id: 'w_${now.microsecondsSinceEpoch}', name: 'Water ($ml ml)', calories: 0, proteinGrams: 0, carbsGrams: 0, fatGrams: 0, timestamp: now, portionGrams: ml)];
    await Future.wait([StorageService.saveWaterIntake(water + ml), StorageService.saveFoodLogs(nextFoods)]);
    if (!mounted) return;
    setState(() { water += ml; foods = nextFoods; });
    widget.onDataChanged();
  }
  Future<void> setWater(int ml) async {
    final amount = ml.clamp(0, 20000).toInt();
    final now = DateTime.now();
    final nextFoods = foods.where((f) => !(today(f.timestamp) && f.name.startsWith('Water ('))).toList();
    if (amount > 0) nextFoods.add(FoodLogItem(id: 'w_${now.microsecondsSinceEpoch}', name: 'Water ($amount ml)', calories: 0, proteinGrams: 0, carbsGrams: 0, fatGrams: 0, timestamp: now, portionGrams: amount));
    await Future.wait([StorageService.saveWaterIntake(amount), StorageService.saveFoodLogs(nextFoods)]);
    if (!mounted) return;
    setState(() { water = amount; foods = nextFoods; });
    widget.onDataChanged();
  }
  Future<void> toggle(TaskItem t) async { final i=tasks.indexWhere((x)=>x.id==t.id); final next=[...tasks]..[i]=t.copyWith(isCompleted: !t.isCompleted, completedAt: !t.isCompleted ? DateTime.now() : null); await StorageService.saveTasks(next); setState(()=>tasks=next); widget.onDataChanged(); }
  Future<void> preset(String title,String category) async { final next=[...tasks,TaskItem(id:'t_${DateTime.now().microsecondsSinceEpoch}',title:title,category:category,priority:'Medium',dueTime:DateTime.now())]; await StorageService.saveTasks(next); setState(()=>tasks=next); widget.onDataChanged(); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Added: $title'))); }
  Future<void> logProtein(String name,int grams) async { final next=[...foods,FoodLogItem(id:'p_${DateTime.now().microsecondsSinceEpoch}',name:name,calories:0,proteinGrams:grams.toDouble(),carbsGrams:0,fatGrams:0,timestamp:DateTime.now())]; await StorageService.saveFoodLogs(next); setState(()=>foods=next); widget.onDataChanged(); }

  @override Widget build(BuildContext context) {
    final open=tasks.where((t)=>todayOrPast(t.dueTime)&&!t.isCompleted).toList()..sort((a,b)=>(a.dueTime??DateTime(2100)).compareTo(b.dueTime??DateTime(2100)));
    return Scaffold(backgroundColor: const Color(0xFFF7F8FC), body: loading ? const Center(child:CircularProgressIndicator()) : SafeArea(child: RefreshIndicator(onRefresh:load,child:ListView(padding:const EdgeInsets.fromLTRB(20,16,20,96),children:[
      Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(DateFormat('EEEE, d MMMM').format(DateTime.now()).toUpperCase(),style:const TextStyle(color:Color(0xFF64748B),fontSize:11,fontWeight:FontWeight.w700,letterSpacing:1),overflow:TextOverflow.ellipsis),const SizedBox(height:4),const Text('Build a day you’re proud of.',style:TextStyle(fontSize:23,fontWeight:FontWeight.w800,color:Color(0xFF172033),),maxLines:2)])),const SizedBox(width:10),Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:const Color(0xFFFFF3DF),borderRadius:BorderRadius.circular(14)),child:Text('🔥 $streak',style:const TextStyle(fontWeight:FontWeight.w800,color:Color(0xFFC2410C))))]),const SizedBox(height:20),
      InkWell(onTap:()=>widget.onNavigateToTab(2),borderRadius:BorderRadius.circular(24),child:Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF4F46E5),Color(0xFF7C3AED)]),borderRadius:BorderRadius.circular(24)),child:const Row(children:[Icon(Icons.timer_outlined,color:Colors.white,size:34),SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Ready for deep work?',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.w800)),SizedBox(height:4),Text('Start a focused session — one task at a time.',style:TextStyle(color:Color(0xFFE0E7FF),fontSize:12))])),Icon(Icons.arrow_forward,color:Colors.white)]))),const SizedBox(height:26),
      section('Today’s priorities','${open.length} open'),...open.take(3).map(task),if(open.isEmpty) empty('Nothing urgent. Add a task or use a preset.'),TextButton(onPressed:()=>widget.onNavigateToTab(1),child:const Text('See all tasks')),const SizedBox(height:14),section('Keep your engine running','Small wins count'),const SizedBox(height:10),Row(children:[Expanded(child:metric(Icons.water_drop_outlined,const Color(0xFF0EA5E9),'Hydration','$water / $waterGoal ml',water/waterGoal,waterSheet,'Log water')),const SizedBox(width:12),Expanded(child:metric(Icons.egg_alt_outlined,const Color(0xFFF59E0B),'Protein','$protein / $proteinGoal g',protein/proteinGoal,proteinSheet,'Log meal'))]),const SizedBox(height:18),section('Health & consistency',''),const SizedBox(height:10),Row(children:[Expanded(child:healthCard('BMI & plans','Goals made simple',Icons.monitor_weight_outlined,const Color(0xFF4F46E5),plans,actionLabel:'Explore plans →',badgeText:'Personalized')),const SizedBox(width:12),Expanded(child:healthCard('Habits','Build your streak',Icons.local_fire_department_outlined,const Color(0xFFF97316),habitsPage,actionLabel:'Track streak 🔥',badgeText:'Daily streak'))]),const SizedBox(height:12),Row(children:[Expanded(child:healthCard('AI calorie','Scan meals fast',Icons.camera_alt_outlined,const Color(0xFF0EA5E9),scanFood,actionLabel:'Scan meal 📸',badgeText:'Instant AI')),const SizedBox(width:12),Expanded(child:healthCard('Exercise','Steps & workouts',Icons.directions_run_outlined,const Color(0xFF10B981),fitness,actionLabel:'Log workout ⚡',badgeText:'Workouts'))])
    ]))));
  }
  Widget section(String title, String sub) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF172033)),
        ),
      ),
      if (sub.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
    ],
  );
  Widget task(TaskItem t)=>Container(margin:const EdgeInsets.only(top:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(children:[InkWell(onTap:()=>toggle(t),child:Container(width:24,height:24,decoration:BoxDecoration(border:Border.all(color:indigo,width:2),borderRadius:BorderRadius.circular(7)))),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t.title,style:const TextStyle(fontWeight:FontWeight.w700,color:Color(0xFF172033))),const SizedBox(height:4),Text('${t.category}  •  ${DateFormat('h:mm a').format(t.dueTime!)}',style:const TextStyle(fontSize:12,color:Color(0xFF64748B)))])),Text(t.priority=='High'?'🔥':t.priority=='Medium'?'⚡':'🌱') ]));
  Widget metric(IconData icon,Color color,String title,String value,double progress,VoidCallback action,String label)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:color),const SizedBox(height:10),Text(title,style:const TextStyle(fontWeight:FontWeight.w700,color:Color(0xFF172033))),Text(value,style:const TextStyle(fontSize:11,color:Color(0xFF64748B))),const SizedBox(height:9),LinearProgressIndicator(value:progress.clamp(0,1).toDouble(),color:color,backgroundColor:const Color(0xFFE2E8F0),borderRadius:BorderRadius.circular(10)),const SizedBox(height:8),InkWell(onTap:action,child:Text(label,style:TextStyle(color:color,fontSize:12,fontWeight:FontWeight.w800)))]));
  Widget healthCard(String title,String subtitle,IconData icon,Color color,VoidCallback action,{required String actionLabel,required String badgeText})=>AspectRatio(aspectRatio:1.0,child:Material(color:Colors.transparent,child:InkWell(onTap:action,borderRadius:BorderRadius.circular(22),child:Container(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Colors.white,color.withOpacity(0.04),color.withOpacity(0.08)]),borderRadius:BorderRadius.circular(22),border:Border.all(color:color.withOpacity(0.2),width:1.5),boxShadow:[BoxShadow(color:color.withOpacity(0.10),blurRadius:16,offset:const Offset(0,6)),const BoxShadow(color:Color(0x08000000),blurRadius:4,offset:Offset(0,2))]),child:ClipRRect(borderRadius:BorderRadius.circular(22),child:Stack(children:[Positioned(top:-24,right:-24,child:Container(width:90,height:90,decoration:BoxDecoration(shape:BoxShape.circle,color:color.withOpacity(0.08)))),Positioned(top:-10,right:-10,child:Container(width:55,height:55,decoration:BoxDecoration(shape:BoxShape.circle,color:color.withOpacity(0.12)))),Positioned(bottom:-30,right:-30,child:Container(width:80,height:80,decoration:BoxDecoration(shape:BoxShape.circle,color:color.withOpacity(0.04)))),Padding(padding:const EdgeInsets.all(14.0),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:44,height:44,decoration:BoxDecoration(gradient:LinearGradient(colors:[color.withOpacity(0.20),color.withOpacity(0.10)],begin:Alignment.topLeft,end:Alignment.bottomRight),borderRadius:BorderRadius.circular(14),border:Border.all(color:color.withOpacity(0.3),width:1),boxShadow:[BoxShadow(color:color.withOpacity(0.15),blurRadius:8,offset:const Offset(0,3))]),child:Icon(icon,color:color,size:24)),Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:3),decoration:BoxDecoration(color:color.withOpacity(0.12),borderRadius:BorderRadius.circular(8)),child:Text(badgeText,style:TextStyle(fontSize:10,fontWeight:FontWeight.w700,color:color)))]),const Spacer(),Text(title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:Color(0xFF172033),letterSpacing:-0.2)),const SizedBox(height:2),Text(subtitle,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w500,color:Color(0xFF64748B))),const SizedBox(height:8),Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),decoration:BoxDecoration(color:color.withOpacity(0.12),borderRadius:BorderRadius.circular(10)),child:Row(mainAxisSize:MainAxisSize.min,children:[Flexible(child:Text(actionLabel,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:color)))]))]))]))))));
  Widget chip(String label,IconData icon,VoidCallback action)=>ActionChip(avatar:Icon(icon,size:16,color:indigo),label:Text(label),labelStyle:const TextStyle(color:Color(0xFF312E81),fontWeight:FontWeight.w600),backgroundColor:const Color(0xFFF0F1FF),side:BorderSide.none,onPressed:action);
  Widget empty(String text)=>Padding(padding:const EdgeInsets.symmetric(vertical:18),child:Text(text,style:const TextStyle(color:Color(0xFF64748B))));
  void plans() => Navigator.push(context, SmoothFadeSlideRoute(page: PlansScreen(onPlanActivated: () { load(); widget.onDataChanged(); })));
  void habitsPage() => Navigator.push(context, SmoothFadeSlideRoute(page: HabitScreen(onHabitUpdated: () { load(); widget.onDataChanged(); })));
  void scanFood() => Navigator.push(context, SmoothFadeSlideRoute(page: FoodScannerScreen(onFoodLogged: () { load(); widget.onDataChanged(); })));
  void fitness() => Navigator.push(context, SmoothFadeSlideRoute(page: const FitnessScreen())).then((_) { load(); widget.onDataChanged(); });
  void waterSheet() { final amount = TextEditingController(text: '$water'); showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Log water', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('$water of $waterGoal ml today', style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () { Navigator.pop(ctx); logWater(250); }, child: const Text('+250 ml'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: () { Navigator.pop(ctx); logWater(500); }, style: FilledButton.styleFrom(backgroundColor: indigo), child: const Text('+500 ml'))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Set today\'s hydration total', suffixText: 'ml', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: OutlinedButton(onPressed: () { Navigator.pop(ctx); setWater(0); }, child: const Text('Reset today'))), const SizedBox(width: 10), Expanded(child: FilledButton(onPressed: () { Navigator.pop(ctx); setWater(int.tryParse(amount.text) ?? water); }, style: FilledButton.styleFrom(backgroundColor: indigo), child: const Text('Save total')))]),
        ],
      ),
    ),
  );
  }
  void proteinSheet()=>showModalBottomSheet(context:context,backgroundColor:Colors.white,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),builder:(ctx)=>Padding(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Log a student meal',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:[['🥚 2 Eggs',12],['🥤 Whey scoop',24],['🧀 Paneer 100g',18],['🍗 Chicken 100g',31],['🫘 Soy chunks',26],['🥣 Dal / lentils',14],['🥣 Oats + milk',12],['🥜 Peanut butter',8]].map((m)=>ActionChip(label:Text('${m[0]}  •  ${m[1]}g'),onPressed:(){Navigator.pop(ctx);logProtein(m[0] as String,m[1] as int);})).toList())])));
  Future<void> calculator() async {
    final curWeight = await StorageService.loadCurrentWeight();
    final curHeight = await StorageService.loadHeight();
    final curAge = await StorageService.loadAge();
    final curSex = await StorageService.loadSex();
    final curActivity = await StorageService.loadActivityLevel();

    if (!mounted) return;

    final w = TextEditingController(text: curWeight.toStringAsFixed(1));
    final h = TextEditingController(text: curHeight.toStringAsFixed(0));
    final a = TextEditingController(text: curAge.toString());
    String sex = curSex;
    String activity = curActivity;

    showModalBottomSheet(context:context,isScrollControlled:true,backgroundColor:Colors.white,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(28))),builder:(ctx)=>StatefulBuilder(builder:(ctx,setSheet){
      final bmr=10*(double.tryParse(w.text)??curWeight)+6.25*(double.tryParse(h.text)??curHeight)-5*(double.tryParse(a.text)??curAge)+(sex=='Male'?5:-161);
      final mult={'Low':1.2,'Light':1.375,'Moderate':1.55,'High':1.725}[activity]??1.55;
      final tdee=(bmr*mult).round();
      final pg=((double.tryParse(w.text)??curWeight)*1.6).round();

      return Padding(padding:EdgeInsets.fromLTRB(24,20,24,MediaQuery.of(ctx).viewInsets.bottom+26),child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Calorie & protein goals',style:TextStyle(fontSize:22,fontWeight:FontWeight.w800,color:Color(0xFF172033))),const SizedBox(height:6),const Text('Mifflin–St Jeor estimate, tuned for student life.',style:TextStyle(color:Color(0xFF64748B))),const SizedBox(height:20),Row(children:[field(w,'Weight (kg)',setSheet),const SizedBox(width:8),field(h,'Height (cm)',setSheet),const SizedBox(width:8),field(a,'Age',setSheet)]),const SizedBox(height:12),Row(children:[Expanded(child:select('Sex',sex,['Male','Female'],(v)=>setSheet(()=>sex=v!))),const SizedBox(width:8),Expanded(child:select('Activity',activity,['Low','Light','Moderate','High'],(v)=>setSheet(()=>activity=v!)))]),const SizedBox(height:18),Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFFF0F1FF),borderRadius:BorderRadius.circular(18)),child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[goal('Maintain','$tdee kcal'),goal('Fat loss','${tdee-350} kcal'),goal('Protein','$pg g')])),const SizedBox(height:18),SizedBox(width:double.infinity,child:FilledButton(onPressed:()async{
        final parsedW=double.tryParse(w.text)??curWeight;
        final parsedH=double.tryParse(h.text)??curHeight;
        final parsedA=int.tryParse(a.text)??curAge;

        await Future.wait([
          StorageService.saveCurrentWeight(parsedW),
          StorageService.saveHeight(parsedH),
          StorageService.saveAge(parsedA),
          StorageService.saveSex(sex),
          StorageService.saveActivityLevel(activity),
          StorageService.saveCalorieGoal(tdee),
          StorageService.saveProteinGoal(pg),
        ]);

        if(!ctx.mounted)return;
        Navigator.pop(ctx);
        load();
      },style:FilledButton.styleFrom(backgroundColor:indigo,padding:const EdgeInsets.all(15)),child:const Text('Apply goals')))])));}));
  }
  Widget field(TextEditingController c,String label,void Function(void Function()) refresh)=>Expanded(child:TextField(controller:c,keyboardType:TextInputType.number,onChanged:(_)=>refresh((){}),decoration:InputDecoration(labelText:label,filled:true,fillColor:const Color(0xFFF8FAFC),border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none))));
  Widget select(String label,String value,List<String> items,ValueChanged<String?> change)=>DropdownButtonFormField(value:value,decoration:InputDecoration(labelText:label,filled:true,fillColor:const Color(0xFFF8FAFC),border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none)),items:items.map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:change);
  Widget goal(String label,String value)=>Column(children:[Text(value,style:const TextStyle(fontWeight:FontWeight.w800,color:Color(0xFF312E81))),Text(label,style:const TextStyle(fontSize:11,color:Color(0xFF64748B)))]);
}
