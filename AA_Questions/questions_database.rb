require 'sqlite3'
require 'singleton'

class QuestionDatabase < SQLite3::Database
  include Singleton
  
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end



class Users
  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    Users.new(data.first) unless data.empty?
  end
  
  def self.find_by_name(fname, lname)
    data = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ?
      AND 
        lname = ?
    SQL
    Users.new(data.first) unless data.empty?
  end 
  
  attr_accessor :fname, :lname, :id
  
  def initialize(opt)
    @fname = opt['fname']
    @lname = opt['lname']
    @id = opt['id']
  end
  
  def authored_questions
    Questions.find_by_author_id(id)
  end
  
  def authored_replies
    Replies.find_by_user_id(id)
  end
  
  def followed_questions
      Questions_Follows.followers_for_user_id(id)
  end

  def liked_questions
    Questions_Follows.liked_questions_for_user_id(id)
  end
end

class Questions
  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Questions.new(data.first) unless data.empty?
  end
  
  def self.find_by_title(title)
    data = QuestionDatabase.instance.execute(<<-SQL, title)
      SELECT
        *
      FROM
        questions
      WHERE
        title = ?
    SQL
    Questions.new(data.first) unless data.empty?
  end
  
  def self.find_by_author_id(author_id)
    data = QuestionDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    data.map {|datum| Questions.new(datum)}
  end
  
  def self.most_followed(n)
    Question_Follows.most_followed_questions(1)
  end

  def self.most_liked(n)
    Question_Likes.most_liked_questions(n)
  end

  attr_accessor :body, :author_id, :id, :title
  
  def initialize(opt)
    @body = opt['body']
    @author_id = opt['author_id']
    @id = opt['id']
    @title = opt['title']
  end
  
  def author
    Replies.find_by_user_id(author_id)
  end
  
  def replies
    Replies.find_by_question_id(id)
  end
  
  def followers
    Questions_Follows.followers_for_question_id(id)
  end
  
  def likers
    Questions_Follows.likers_for_question_id(id)
  end
  
  def num_likes
    Questions_Follows.num_likes_for_question_id(id)
  end
end

class Replies
  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    Replies.new(data.first)
  end
  
  def self.find_by_user_id(user_id)
    data = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    data.map {|datum| Replies.new(datum)}
  end

  def self.find_by_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    data.map {|datum| Replies.new(datum)}
  end

  attr_accessor :body, :parent_id, :id, :author_id, :question_id
  
  def initialize(opt)
    @body = opt['body']
    @author_id = opt['author_id']
    @id = opt['id']
    @parent_id = opt['parent_id']
    @question_id = opt['question_id']
  end
  
  def author
    Users.find_by_id(author_id)
  end
  
  def question
    Questions.find_by_id(question_id)
  end
  
  def parent_reply
    Replies.find_by_id(parent_id)
  end
  
  def child_replies
    data = QuestionDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    data.map {|datum| Replies.new(datum)}
  end
  
end

class Questions_Follows
  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions_follows
      WHERE
        id = ?
    SQL
    Questions_Follows.new(data.first)
  end
  
  def self.followers_for_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        questions_follows
      JOIN 
        users
      ON 
        questions_follows.user_id = users.id 
      WHERE
        question_id = ?
    SQL
    data.map { |datum| Users.new(datum) }
  end 
  
  
  def self.followers_for_user_id(user_id)
    data = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions_follows
      JOIN 
        questions
      ON 
        questions_follows.question_id = questions.id
      WHERE
        user_id = ?
    SQL
    data.map { |datum| Questions.new(datum) }
  end 
  
  def self.most_followed_questions(n)
    data = QuestionDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN
        questions_follows
        ON questions.id = questions_follows.question_id
      GROUP BY
        question_id
      ORDER BY COUNT(user_id) DESC
      LIMIT ?
    SQL
    data.map { |datum| Questions.new(datum) }
  end 
  
  
  
  attr_accessor :question_id, :user_id, :id
  
  def initialize(opt)
    @id = opt['id']
    @author_id = opt['user_id']
    @question_id = opt['question_id']
  end
end

class Question_Likes
  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    Question_Likes.new(data.first)
  end
  
  def self.likers_for_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_likes
      JOIN
        users
      ON users.id = question_likes.user_id
      JOIN
        questions
      ON questions.id = question_likes.question_id
      WHERE questions.id = ?
      SQL
      data.map { |datum| Users.new(datum)}
  end 
    
  def self.num_likes_for_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        question_likes
      JOIN
        questions
      ON questions.id = question_likes.question_id
      WHERE questions.id = ?
    SQL
    data.first['COUNT(*)']
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN
        questions
      ON questions.id = question_likes.question_id
      WHERE question_likes.user_id = ?
    SQL
    data.map { |datum| Questions.new(datum)}
  end
  
  def self.most_liked_questions(n)
    data = QuestionDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN
        questions
      ON questions.id = question_likes.question_id
      GROUP BY questions.id
      ORDER BY COUNT(*) DESC
      LIMIT ?
    SQL
    data.map { |datum| Questions.new(datum)}
  end
  
  attr_accessor :user_id, :id, :question_id
  
  def initialize(opt)
    @user_id = opt['user_id']
    @id = opt['id']
    @question_id=opt['question_id']
  end
end