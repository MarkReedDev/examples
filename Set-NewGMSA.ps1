# Saved as a reminder due to lack of on-line information.
# -KerberosEncryptionType has proved vital in the past. 

New-ADServiceAccount -Name "<name>" -DNSHostName <dns name> -KerberosEncryptionType AES128,AES256 -PrincipalsAllowedToRetrieveManagedPassword <servers>
