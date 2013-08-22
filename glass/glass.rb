require 'sqlite3'
require 'sinatra'
require 'erubis'

enable :sessions

$username = "admin"
$password = "root"

def init_db()
    file = File.open('schema.sql', 'r')
    sql = file.read
    file.close
    db = SQLite3::Database.new('test.db')
    db.transaction
    db.execute sql
    db.commit
    db.close
end

#init_db()

$error = nil

before do
    $db = SQLite3::Database.open('test.db')
end

after do
    $db.close
end

get '/' do
    posts = $db.execute('select title, text from entries order by id desc')
    erb :show_entries, :locals => {:posts => posts}
end

post '/add' do
    $db.execute('insert into entries (title, text) values (?, ?)', params[:title], params[:text])
    redirect ''
end

get '/login' do
    erb :login, :locals=> {:error => $error}
end

post '/login' do
    if params[:username] != $username
        $error = "Invalid username"
    elsif params[:password] != $password
        $error = "Invalid password"
    else
        session['logged_in'] = true
        redirect ''
    end
    return redirect '/login'
end

get '/logout' do
    session.clear
    redirect ''
end
