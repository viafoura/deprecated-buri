import com.netflix.asgard.model.HardwareProfile
import com.netflix.asgard.model.InstanceTypeData

grails.awsAccounts = [ {% for acct in asgard_accounts %}{% if not loop.last %}, {% endif %}'{{ asgard_accounts[acct].account_no }}'{% endfor %} ]
grails.awsAccountNames = [ {% for acct in asgard_accounts %}{% if not loop.last %}, {% endif %}'{{ asgard_accounts[acct].account_no }}': '{{ acct }}'{% endfor %} ]

cloud {
	accountName = '{{ asgard_nickname }}'
	envStyle = '{{ asgard_envstyle }}'
	defaultKeyName = '{{ asgard_default_key }}'
}


