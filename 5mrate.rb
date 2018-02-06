require 'open-uri'
require 'nokogiri'
require 'robotex'
require 'date'
require 'csv'
require 'mail'

a=["mxn","try","usd"]
data=[[],[],[]]
loop do




#�����̐ݒ�
t=Time.now
day=t.strftime("%m/%d")
time=t.strftime("%H:%M")
rates=[day,time]




#�ʉ݂��ƂɌJ��Ԃ�����
n=0
while n<3 do




#�X�N���C�s���O���Ĕz��ɒǉ�
url="http://"+a[n]+".jp.fxexchangerate.com/jpy/"
robotex = Robotex.new
p robotex.allowed?(url)
user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.63 Safari/537.36'
charset = nil
html = open(url, "User-Agent" => user_agent) do |f|
charset = f.charset
f.read
end
doc=Nokogiri::HTML.parse(html, nil, charset)

rate=doc.css("p")[3].text
ratef=rate.to_f
rates.push(ratef)




#30�񕪂̕��ϒl�����߂�
data[n].push(ratef)
if data[n].length>30
data[n].delete_at(0)
end
datan=data[n]
len=datan.length
m=0
datatotal=0
while m<len do
datatotal+=datan[m]
m+=1
end
ave=datatotal/len




#�W���΍��Ɓ}3�Ђ����߂�
x=0
m=0
while m<len do
x+=(ave-datan[m])**2/len
m+=1
end
s=x**(1/2.0)
p3=ave+s*3
m3=ave-s*3




#�}3�Ђ��O�ꂽ���Ɏ����Ƀ��[�����鏈��
if p3<ratef
mail = Mail.new do
from    "address@gmail.com"
to      "address@gmail.com"
subject a[n]+"/jpy +3 over"
body   a[n]+"/jpy rate  "+ratef.to_s
end
mail.delivery_method(:smtp,
address:        'smtp.gmail.com',
port:           587,
domain:         'smtp.gmail.com',
authentication: :login,
user_name:      "address@gmail.com",
password:       "password"
)
mail.deliver
end

if m3>ratef
mail = Mail.new do
from    "address@gmail.com"
to      "address@gmail.com"
subject a[n]+"/jpy -3 over"
body   a[n]+"/jpy rate  "+ratef.to_s
end
mail.delivery_method(:smtp,
address:        'smtp.gmail.com',
port:           587,
domain:         'smtp.gmail.com',
authentication: :login,
user_name:      "address@gmail.com",
password:       "password"
)
mail.deliver
end




n+=1
end




#CSV�t�@�C���ɒǉ�
CSV.open("5m.csv", "a") do |b|
b<<rates
end




#5�����ɓ�������������ׂ̎��Ԃ̒���
t1=Time.now
t2=t1-t
sleep(300-t2)
end