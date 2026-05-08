create database if not exists Session04;
use Session04;

create table teachers (
    teacher_id int auto_increment primary key,
    fullname varchar(100) not null,
    email varchar(100) not null unique
);

create table students (
    student_id int auto_increment primary key,
    fullname varchar(100) not null,
    date_of_birth date,
    email varchar(100) not null unique
);

create table courses (
    course_id int auto_increment primary key,
    course_name varchar(150) not null,
    description varchar(300),
    total_sessions int check (total_sessions > 0),
    teacher_id int not null,

    foreign key (teacher_id) references teachers(teacher_id)
);

create table enrollments (
    student_id int,
    course_id int,
    enroll_date date default (current_date),

    primary key (student_id, course_id),

    foreign key (student_id) references students(student_id),
    foreign key (course_id) references courses(course_id)
);

create table scores (
    student_id int,
    course_id int,
    midterm_score decimal(4,2) check (midterm_score between 0 and 10),
    final_score decimal(4,2) check (final_score between 0 and 10),

    primary key (student_id, course_id),

    foreign key (student_id) references students(student_id),
    foreign key (course_id) references courses(course_id)
);


insert into teachers(fullname, email)
values
('Nguyen Van A', 'a@gmail.com'),
('Tran Thi B', 'b@gmail.com');


insert into courses(course_name, description, total_sessions, teacher_id)
values
('Java Core', 'Khoa hoc Java co ban', 20, 1),
('SQL Basic', 'Hoc SQL tu co ban den nang cao', 15, 2);

insert into students(fullname, date_of_birth, email)
values
('Le Van Nam', '2004-05-12', 'nam@gmail.com'),
('Pham Thi Hoa', '2003-11-20', 'hoa@gmail.com');

insert into enrollments(student_id, course_id)
values
(1, 1),
(1, 2),
(2, 1);

insert into scores(student_id, course_id, midterm_score, final_score)
values
(1, 1, 8.5, 9.0),
(1, 2, 7.5, 8.0),
(2, 1, 6.5, 7.0);

update teachers
set email = 'newemail@gmail.com'
where teacher_id = 1;

update courses
set total_sessions = 25
where course_id = 1;

update scores
set final_score = 9.5
where student_id = 1 and course_id = 1;

delete from scores
where student_id = 2 and course_id = 1;