<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Agency_ACR_Approval</fullName>
        <description>Agency ACR Approval</description>
        <protected>false</protected>
        <recipients>
            <field>Main_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>cdfa.dms_as_rsa@cdfa.ca.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agency_Approval</template>
    </alerts>
    <alerts>
        <fullName>Agency_Added_Agent</fullName>
        <description>Agency Added Agent</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>cdfa.dms_as_rsa@cdfa.ca.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agency_Added_Agent</template>
    </alerts>
    <alerts>
        <fullName>Agency_Approved</fullName>
        <description>Agency Approved</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>cdfa.dms_as_rsa@cdfa.ca.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agency_Approved</template>
    </alerts>
    <alerts>
        <fullName>Agency_Inactivates</fullName>
        <description>Agency Inactivates</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>cdfa.dms_as_rsa@cdfa.ca.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agency_Inactivated_Agent</template>
    </alerts>
    <alerts>
        <fullName>Agency_Rejected</fullName>
        <description>Agency Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>cdfa.dms_as_rsa@cdfa.ca.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agency_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Agent_Inactivates</fullName>
        <description>Agent Inactivates</description>
        <protected>false</protected>
        <recipients>
            <field>Main_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>cdfa.dms_as_rsa@cdfa.ca.gov</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agent_Inactivated_Agency</template>
    </alerts>
    <rules>
        <fullName>Agency ACR Approval</fullName>
        <actions>
            <name>Agency_ACR_Approval</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(TaskId__c ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Agency Added Agent</fullName>
        <actions>
            <name>Agency_Added_Agent</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AccountContactRelation.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>AccountContactRelation.Initiated_By__c</field>
            <operation>equals</operation>
            <value>Agency</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Agency Approved</fullName>
        <actions>
            <name>Agency_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AccountContactRelation.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>AccountContactRelation.Initiated_By__c</field>
            <operation>equals</operation>
            <value>Agent</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Agency Inactivates</fullName>
        <actions>
            <name>Agency_Inactivates</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AccountContactRelation.Action__c</field>
            <operation>equals</operation>
            <value>Agency Inactivation</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Agency Rejected</fullName>
        <actions>
            <name>Agency_Rejected</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AccountContactRelation.Action__c</field>
            <operation>equals</operation>
            <value>Agency Rejection</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Agent Inactivates</fullName>
        <actions>
            <name>Agent_Inactivates</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AccountContactRelation.Action__c</field>
            <operation>equals</operation>
            <value>Agent Inactivation</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
