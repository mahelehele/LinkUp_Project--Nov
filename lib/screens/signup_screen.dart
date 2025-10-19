import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _studentNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedCourse;
  String? _selectedYear;
  String? _selectedFaculty;
  String? _selectedCampus;

  bool _isLoading = false;
  bool _obscurePassword = true;

  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _faculties = [];
  List<Map<String, dynamic>> _campuses = [];
  final List<String> _years = ['first year','second year','third year','fourth year','postgrad'];

  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await _loadCachedData();
      await _fetchDataFromApi();
    } catch (error) {
      print('Error loading initial data: $error');
    }
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedCourses = prefs.getStringList('cached_courses');
    if (cachedCourses != null) {
      setState(() {
        _courses = cachedCourses.map((course) => {
          'id': int.tryParse(course.split('|')[0]) ?? 0,
          'course_name': course.split('|')[1],
        }).toList();
      });
    }
    final cachedFaculties = prefs.getStringList('cached_faculties');
    if (cachedFaculties != null) {
      setState(() {
        _faculties = cachedFaculties.map((faculty) => {
          'id': int.tryParse(faculty.split('|')[0]) ?? 0,
          'faculty_name': faculty.split('|')[1],
        }).toList();
      });
    }
    final cachedCampuses = prefs.getStringList('cached_campuses');
    if (cachedCampuses != null) {
      setState(() {
        _campuses = cachedCampuses.map((campus) => {
          'id': int.tryParse(campus.split('|')[0]) ?? 0,
          'campus_name': campus.split('|')[1],
        }).toList();
      });
    }
  }

  Future<void> _fetchDataFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesResponse = await _apiService.get('/courses');
      if (coursesResponse['success']) {
        final courses = List<Map<String, dynamic>>.from(coursesResponse['courses']);
        setState(() => _courses = courses);
        await prefs.setStringList('cached_courses', courses.map((c) => '${c['id']}|${c['course_name']}').toList());
      }
      final facultiesResponse = await _apiService.get('/faculties');
      if (facultiesResponse['success']) {
        final faculties = List<Map<String, dynamic>>.from(facultiesResponse['faculties']);
        setState(() => _faculties = faculties);
        await prefs.setStringList('cached_faculties', faculties.map((f) => '${f['id']}|${f['faculty_name']}').toList());
      }
      final campusesResponse = await _apiService.get('/campuses');
      if (campusesResponse['success']) {
        final campuses = List<Map<String, dynamic>>.from(campusesResponse['campuses']);
        setState(() => _campuses = campuses);
        await prefs.setStringList('cached_campuses', campuses.map((c) => '${c['id']}|${c['campus_name']}').toList());
      }
    } catch (error) {
      print('Error fetching API data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC0CB), // Soft pink background
      appBar: AppBar(
        title: const Text('Student Registration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading && _courses.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildSurnameField(),
                    const SizedBox(height: 16),
                    _buildStudentNumberField(),
                    const SizedBox(height: 16),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    _buildCourseDropdown(),
                    const SizedBox(height: 16),
                    _buildYearDropdown(),
                    const SizedBox(height: 16),
                    _buildFacultyDropdown(),
                    const SizedBox(height: 16),
                    _buildCampusDropdown(),
                    const SizedBox(height: 16),
                    _buildPhoneField(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Icon(Icons.school, size: 64, color: Colors.white),
        SizedBox(height: 8),
        Text('Create Student Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        Text('Fill in your details to register', style: TextStyle(fontSize: 14, color: Colors.white70)),
      ],
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.pinkAccent),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
    );
  }

  Widget _buildNameField() => TextFormField(controller: _nameController, decoration: _fieldDecoration('Name', Icons.person), validator: (v){if(v==null||v.isEmpty) return 'Enter name'; return null;});
  Widget _buildSurnameField() => TextFormField(controller: _surnameController, decoration: _fieldDecoration('Surname', Icons.person_outline), validator: (v){if(v==null||v.isEmpty) return 'Enter surname'; return null;});
  Widget _buildStudentNumberField() => TextFormField(controller: _studentNumberController, decoration: _fieldDecoration('Student Number', Icons.badge), keyboardType: TextInputType.number, maxLength: 9, validator: (v){if(v==null||v.length!=9) return 'Must be 9 digits'; return null;});
  Widget _buildEmailField() => TextFormField(controller: _emailController, decoration: _fieldDecoration('Email', Icons.email), keyboardType: TextInputType.emailAddress, validator: (v){if(v==null||!v.contains('@')) return 'Enter valid email'; return null;});
  Widget _buildPasswordField() => TextFormField(controller: _passwordController, obscureText: _obscurePassword, decoration: _fieldDecoration('Password', Icons.lock).copyWith(suffixIcon: IconButton(icon: Icon(_obscurePassword?Icons.visibility:Icons.visibility_off,color: Colors.pinkAccent), onPressed: (){setState(()=>_obscurePassword=!_obscurePassword);},)), validator: (v){if(v==null||v.length<8) return 'At least 8 chars'; return null;});
  Widget _buildCourseDropdown() => DropdownButtonFormField<String>(value:_selectedCourse, decoration:_fieldDecoration('Course', Icons.menu_book), items:_courses.map((c)=>DropdownMenuItem(value:c['id'].toString(),child: Text(c['course_name']))).toList(), onChanged:(v)=>setState(()=>_selectedCourse=v), validator:(v){if(v==null||v.isEmpty)return 'Select course'; return null;});
  Widget _buildYearDropdown() => DropdownButtonFormField<String>(value:_selectedYear, decoration:_fieldDecoration('Year of Study', Icons.calendar_today), items:_years.map((y)=>DropdownMenuItem(value:y,child: Text(y))).toList(), onChanged:(v)=>setState(()=>_selectedYear=v), validator:(v){if(v==null||v.isEmpty)return 'Select year'; return null;});
  Widget _buildFacultyDropdown() => DropdownButtonFormField<String>(value:_selectedFaculty, decoration:_fieldDecoration('Faculty', Icons.account_balance), items:_faculties.map((f)=>DropdownMenuItem(value:f['id'].toString(),child: Text(f['faculty_name']))).toList(), onChanged:(v)=>setState(()=>_selectedFaculty=v), validator:(v){if(v==null||v.isEmpty)return 'Select faculty'; return null;});
  Widget _buildCampusDropdown() => DropdownButtonFormField<String>(value:_selectedCampus, decoration:_fieldDecoration('Campus', Icons.location_on), items:_campuses.map((c)=>DropdownMenuItem(value:c['id'].toString(),child: Text(c['campus_name']))).toList(), onChanged:(v)=>setState(()=>_selectedCampus=v), validator:(v){if(v==null||v.isEmpty)return 'Select campus'; return null;});
  Widget _buildPhoneField() => TextFormField(controller:_phoneController, decoration:_fieldDecoration('Phone Number', Icons.phone), keyboardType: TextInputType.phone, maxLength: 10, validator:(v){if(v==null||v.length!=10)return 'Must be 10 digits'; return null;});

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _isLoading ? null : _submitForm,
      icon: _isLoading
          ? const SizedBox(width: 16,height: 16,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2))
          : const Icon(Icons.app_registration, size: 20),
      label: _isLoading
          ? const Text('PROCESSING...')
          : const Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account? ', style: TextStyle(color: Colors.white)),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/signin'),
          child: const Text('Sign In', style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(()=>_isLoading=true);
      try {
        final result = await _authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          {
            'studentNumber': _studentNumberController.text,
            'name': _nameController.text,
            'surname': _surnameController.text,
            'course': _selectedCourse,
            'year': _selectedYear,
            'faculty': _selectedFaculty,
            'campus': _selectedCampus,
            'phone': _phoneController.text,
          },
        );
        setState(()=>_isLoading=false);
        if(result['success']==true)_showSuccessDialog();
        else _showErrorDialog(result['error']??'Registration failed.');
      } catch(error){
        setState(()=>_isLoading=false);
        _showErrorDialog('Error: $error');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(context: context, builder: (context)=>AlertDialog(
      backgroundColor: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.pinkAccent, size: 48),
      title: const Text('Registration Successful', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text('Your student account has been created successfully.', textAlign: TextAlign.center),
      actions: [Center(child: ElevatedButton.icon(
        onPressed: (){
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, '/signin');
        },
        icon: const Icon(Icons.done,size:18),
        label: const Text('CONTINUE TO LOGIN'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
      ))],
    ));
  }

  void _showErrorDialog(String message) {
    showDialog(context: context, builder: (context)=>AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Registration Failed'),
      content: Text(message, style: const TextStyle(color: Colors.black87)),
      actions: [TextButton(onPressed: ()=>Navigator.of(context).pop(), child: const Text('OK'))],
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _studentNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
