String jobPostedLabel(String? updatedAt) {
  if (updatedAt == null || updatedAt.isEmpty) return 'Just now';
  final parsed = DateTime.tryParse(updatedAt);
  if (parsed == null) return 'Just now';
  final diff = DateTime.now().difference(parsed.toLocal());
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 30) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  return '${diff.inDays ~/ 30} month${diff.inDays ~/ 30 == 1 ? '' : 's'} ago';
}

class DemoJob {
  final String id;
  final String company;
  final String title;
  final String category;
  final String location;
  final String experienceLevel;
  final String salary;
  final String vacancies;
  final String posted;
  final String lastDate;
  final bool applied;

  const DemoJob({
    required this.id,
    required this.company,
    required this.title,
    required this.category,
    required this.location,
    required this.experienceLevel,
    required this.salary,
    required this.vacancies,
    required this.posted,
    required this.lastDate,
    this.applied = false,
  });

  String get description =>
      'Demo listing for $title at $company. This job appears in the feed '
      'when the live jobs collection is empty or offline.';
}

const List<DemoJob> kDemoJobs = [
  DemoJob(
    id: 'demo-kervia-partner',
    company: 'Kervia',
    title: 'Kervia Working Patner',
    category: 'Telecaller',
    location: 'Ambalappuzha, Alappuzha',
    experienceLevel: 'Fresher',
    salary: '₹2,500 / monthly',
    vacancies: '78 vacancies',
    posted: '1 day ago',
    lastDate: 'No deadline',
    applied: true,
  ),
  DemoJob(
    id: 'demo-kervia-coordinator',
    company: 'Kervia',
    title: 'Kervia Working Coordinator',
    category: 'Recruiter',
    location: 'Eranad, Malappuram',
    experienceLevel: '1+ years',
    salary: '₹10,000 / monthly',
    vacancies: '1 vacancies',
    posted: '1 day ago',
    lastDate: 'No deadline',
    applied: true,
  ),
  DemoJob(
    id: 'demo-software-tester',
    company: 'Test',
    title: 'Software tester',
    category: 'Software Tester',
    location: 'Tirur, Malappuram',
    experienceLevel: 'Fresher',
    salary: '₹25,000 / monthly',
    vacancies: '1 vacancies',
    posted: '1 day ago',
    lastDate: 'No deadline',
    applied: true,
  ),
  DemoJob(
    id: 'demo-software-engineer',
    company: 'Test',
    title: 'Software Engineer',
    category: 'Software Engineer',
    location: 'Kunnathunad, Ernakulam',
    experienceLevel: '10+ years',
    salary: '₹100 / hourly',
    vacancies: '1 vacancies',
    posted: '1 day ago',
    lastDate: 'No deadline',
  ),
  DemoJob(
    id: 'demo-sales-associate',
    company: 'Test',
    title: 'Sales Associate',
    category: 'Sales Associate',
    location: 'Kunnathunad, Ernakulam',
    experienceLevel: '0-2 years',
    salary: '₹15,000 / monthly',
    vacancies: '2 vacancies',
    posted: '1 day ago',
    lastDate: 'No deadline',
  ),
  DemoJob(
    id: 'demo-receptionist',
    company: 'Kerala Tourism',
    title: 'Receptionist',
    category: 'Hospitality',
    location: 'Aluva, Ernakulam',
    experienceLevel: '1-3 years',
    salary: '₹18,000 / monthly',
    vacancies: '3 vacancies',
    posted: '2 days ago',
    lastDate: '15 Sep 2026',
  ),
  DemoJob(
    id: 'demo-field-coordinator',
    company: 'Kudumbashree',
    title: 'Field Coordinator',
    category: 'Rural Development',
    location: 'Manjeshwar, Kasaragod',
    experienceLevel: '2-5 years',
    salary: '₹22,000 / monthly',
    vacancies: '2 vacancies',
    posted: '3 days ago',
    lastDate: '20 Sep 2026',
  ),
  DemoJob(
    id: 'demo-office-assistant',
    company: 'KSFE',
    title: 'Office Assistant',
    category: 'Office Assistant',
    location: 'Thodupuzha, Idukki',
    experienceLevel: 'Fresher',
    salary: '₹16,000 / monthly',
    vacancies: '4 vacancies',
    posted: '4 days ago',
    lastDate: 'No deadline',
  ),
  DemoJob(
    id: 'demo-cyber-analyst',
    company: 'Kerala Police',
    title: 'Cyber Security Analyst',
    category: 'IT & Software',
    location: 'Kochi, Ernakulam',
    experienceLevel: '3-6 years',
    salary: '₹45,000 / monthly',
    vacancies: '1 vacancies',
    posted: '5 days ago',
    lastDate: '25 Sep 2026',
  ),
];