import csv
from collections import namedtuple, OrderedDict

Rule = namedtuple('Rule', ['action', 'protocol', 'src_ip', 'src_port', 'direction', 'dst_ip', 'dst_port', 'options'])
Options = namedtuple('Options', ['msg', 'content','sid'])

domain_options = {'msg': 'DNS Request for ',
				  'content': '',
				  'sid': 1000000}

def quote_wrap(s):
	return '"' + s + '"'
				 				  
def get_option_str(d):
	o_str = '('
	for k in d:
		o_str += k + ': '
		if type(d[k]) == int:
			o_str += str(d[k])
		else:
			o_str += '"' + d[k] + '"'
		o_str += '; '
	o_str += ')'
	return o_str


def get_domain(domain):
	d_list = domain.split('.')
	if len(d_list) == 1:
		return d_list[0]
	elif len(d_list) > 1:
		if d_list[-2] in {'com', 'net', 'co', 'us', 'org', 'info', 'update', 'download', 'www'}:
			return d_list[-3]
		return d_list[-2]


with open('iocips.txt') as f:
	lines = f.readlines()
	ip_list = [line.rstrip() for line in lines]

with open('iocdomains.txt') as f:
	lines = f.readlines()
	domain_list = [line.rstrip() for line in lines]

sid = 1100000
for d in domain_list:
	domain = get_domain(d)
	o = Options('DNS Request for ' + domain, domain, sid)
	o_str = get_option_str(o._asdict())
	r = Rule('alert', 'udp', 'any', 'any', '->', 'any', 'any', o_str)
	print(' '.join(r))
	sid += 1

for ip in ip_list:
	o = {'msg': 'Known bad traffic: ' + str(ip), 'sid': sid}
	o_str = get_option_str(o)
	r = Rule('alert', 'ip', ip, 'any', '<>', 'any', 'any', o_str)
	print(' '.join(r))
	sid += 1
