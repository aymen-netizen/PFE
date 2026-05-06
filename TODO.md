<<<<<<< HEAD
# Logout Feature Implementation TODO

## Plan Breakdown
1. [x] Create TODO.md with steps 
2. [x] Edit lib/views/admin/admin_dashboard_screen.dart - add AppBar logout IconButton + _performLogout()
3. [x] Edit lib/views/profile/profile_screen.dart - add import, red logout button + _performLogout()
4. [x] Test navigation: admin/patient login → logout → LoginScreen only (no back)
5. [x] Update TODO.md with completion 
6. [x] Attempt completion

**Logout feature complete:** Admin dashboard has logout icon in AppBar, patient profile has red logout button. Both use pushAndRemoveUntil to LoginScreen, clearing stack.
=======
# MySQL/Sequelize Migration TODO (from MongoDB/Mongoose)

## Status: In Progress

### Prerequisites (User)
- [ ] Create MySQL database: `CREATE DATABASE medical_app;`
- [ ] Update backend/.env with:
  ```
  DB_HOST=localhost
  DB_USER=root
  DB_PASSWORD=yourpassword
  DB_NAME=medical_app
  JWT_SECRET=your_secret
  PORT=5000
  ```
  (Comment out MONGO_URI)

### Steps
- [x] 1. Install Sequelize/MySQL2 (`cd backend & npm install sequelize mysql2`)
- [ ] 2. Remove mongoose from backend/package.json
- [ ] 3. Replace backend/src/config/database.js (Sequelize connection + sync)
- [ ] 4. Rewrite models: src/models/User.js, Doctor.js, Appointment.js (sequelize.define + associations)
- [ ] 5. Update services: userService.js (register/login queries)
- [ ] 6. Update services: doctorService.js (CRUD)
- [ ] 7. Update services: appointmentService.js (create/get/update/delete + includes)
- [ ] 8. Update src/middleware/auth.js (User.findById)
- [ ] 9. `cd backend && npm install` (after package.json update)
- [ ] 10. Test: `npm run dev`, POST /auth/register, GET /doctors, etc.
- [ ] 11. Verify Flutter frontend APIs work

**Completed steps will be marked [x]**
>>>>>>> 638a4100a020c08459a189de47acf411a019a7ce
