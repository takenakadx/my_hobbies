require "date"

def isMatch(str)
	$control_game_name.each do |elem|
		if (/#{elem}/i =~ str) != nil
			return true
			break
		end
	end
	return false
end

def task_search
	output = `tasklist /FO CSV /NH`
	d_output = output.delete(%Q["])

	task = Array.new
	output.each_line do |line|
		s = line.split(",")
		if isMatch(s[0])
			task << s[1]	#same as task.push 
		end
	end
	return task

=begin
	task = Array.new

	process_list = WIN32OLE.connect("winmgmts:").InstancesOf("Win32_process")
  	process_list.each do |process|
  		if isMatch(process.Name)
  			task << process.ProcessId
  		end
    	#print "name:",process.Name,"\tID",process.ProcessId,"\n"
 	end

	return task
=end
end

def task_kill(tas)
	tas.each { |pid| `taskkill /pid #{pid} /F`}
end

#__________________________________________check date_____________________________________
class ChildData
	def initialize()
		begin
			m_data = File.open("data.d").read.split("\n")
			if (m_nowDate == m_data[1])
				@remainTime = m_data[0].to_i
			else
				dateReset
			end
		rescue
			File.open("data.d","w"){|f| f.puts(initializeDateReset,m_nowDate)}
		end
	end

	def initializeDateReset
		a = 0
		file = File.open("properties.pro").read.split("\n")
		resetDatas = file[2]
		r_d = resetDatas.split(",")
		temp = r_d[Date.today.wday].split("|")
		if(DateTime.now.hour >= 12)
			a = temp[1].to_i * 60
		else
			a = temp[0].to_i * 60
		end
		return a
	end

	def dateReset
		File.open("data.d","w"){|f| f.puts(initializeDateReset,m_nowDate)}
	end

	def m_nowDate
		d = DateTime.now
		if(d.hour >= 12)
			dd = 'a'
		else
			dd = 'p'
		end
		return "#{d.year}#{d.month}#{d.day}#{dd}"
	end

	def checkRemain(t)
		m_data = File.open("data.d").read.split("\n")
		@remainTime = m_data[0].to_i
		@remainTime -= t
		puts @remainTime
		File.open("data.d","w"){|f| f.puts(@remainTime,m_nowDate)}
		if @remainTime <= 0
			return false
		else
			return true
		end
	end
end

def main(t,c)		#t=wait time, c = watching child
	a = task_search
	if a.empty?
		p "there is no game"
	else
		if c.checkRemain(t)
			p "time remains"
		else
			task_kill(a)
		end
	end
end

#______________________________________start____________________________________________________________
file = File.open("properties.pro").read.split("\n")		#read file
waittime = file[0].to_i									#wait time[s]
$control_game_name = file[1].split(",")					#the name of game which are controlled
child = ChildData.new

	loop do	
		main(waittime,child)
		sleep(waittime)
	end

