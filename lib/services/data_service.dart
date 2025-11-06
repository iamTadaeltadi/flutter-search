import '../models/user.dart';


class DataService {
  static List<User> getSampleUsers() {
    return [
      User(
        id: '1',
        name: 'Bob Wilson',
        username: 'master_carpenter',
        occupation: 'Carpenter',
        skills: ['Woodworking', 'Furniture Making'],
        rating: 4.5,
        reviewCount: 32,
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
      ),
      User(
        id: '2',
        name: 'Mike Smith',
        username: 'no_1_car_mechanic',
        occupation: 'Car Mechanic',
        skills: ['Automotive', 'Engine Repair'],
        rating: 4.9,
        reviewCount: 89,
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
      ),
      User(
        id: '3',
        name: 'Alice Brown',
        username: 'car_painter_pro',
        occupation: 'Car Painter',
        skills: ['Automotive', 'Paint Application'],
        rating: 4.6,
        reviewCount: 67,
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
      ),
      User(
        id: '4',
        name: 'John Doe',
        username: 'electrician_john',
        occupation: 'Electrician',
        skills: ['Electrical Work', 'Wiring'],
        rating: 4.7,
        reviewCount: 45,
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
      ),
      User(
        id: '5',
        name: 'Sarah Johnson',
        username: 'plumber_sarah',
        occupation: 'Plumber',
        skills: ['Plumbing', 'Pipe Repair'],
        rating: 4.8,
        reviewCount: 56,
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
      ),
      User(
        id: '6',
        name: 'David Martinez',
        username: 'carpenter_dave',
        occupation: 'Carpenter',
        skills: ['Woodworking', 'Cabinet Making'],
        rating: 4.4,
        reviewCount: 28,
        avatarUrl: 'https://i.pravatar.cc/150?img=6',
      ),
      User(
        id: '7',
        name: 'Emily Chen',
        username: 'auto_mechanic_emily',
        occupation: 'Car Mechanic',
        skills: ['Automotive', 'Diagnostics'],
        rating: 4.9,
        reviewCount: 92,
        avatarUrl: 'https://i.pravatar.cc/150?img=7',
      ),
      User(
        id: '8',
        name: 'Michael Brown',
        username: 'master_painter',
        occupation: 'Car Painter',
        skills: ['Automotive', 'Body Work'],
        rating: 4.5,
        reviewCount: 38,
        avatarUrl: 'https://i.pravatar.cc/150?img=8',
      ),
    ];
  }
}


