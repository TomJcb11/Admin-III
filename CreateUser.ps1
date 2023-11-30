# Importer les utilisateurs d'un fichier CSV
$users = Import-Csv -Path "CheminVersVotreFichierCsv" 

# Choisir l'OU dans laquelle les utilisateurs seront créés
$organizationalunit = "OU=utilisateurs,DC=allinone,DC=lab"

# Récupérer tous les utilisateurs de l'OU
$usersAD = Get-ADUser -Filter * -SearchBase $organizationalunit

# Parcourir tous les utilisateurs du fichier CSV
foreach ($user in $users) {

    # Récupérer les informations de l'utilisateur
    $firstname = $user.Prenom
    $initial = $user.Initiale
    $lastname = $user.Nom
    $fullname = $user.'Nom complet'
    $logonname = $user.'Nom Utilisateur'
    $password = 'User123*'
    # Choisir si l'utilisateur doit être activé ou non
    if($user.Activer -eq 'O'){
        $activate = $false
    }else{
        $activate = $true
    }

    # Vérifier si l'utilisateur existe déjà
    $alreadyexist = Get-ADUser -Filter {SamAccountName -eq $logonname} -SearchBase $organizationalunit

    
    if($alreadyexist){
        # Si l'utilisateur existe déjà, le modifier
        Set-ADUser -Identity $logonname -UserPrincipalName "$logonname@allinone.lab" -GivenName $firstname -Initials $initial -Surname $lastname -DisplayName $fullname -Enabled $activate
    }else{
        # Si l'utilisateur n'existe pas, le créer
        New-ADUser -SamAccountName $logonname -UserPrincipalName "$logonname@allinone.lab" -GivenName $firstname -Initials $initial -Surname $lastname -Path $organizationalunit -Name $fullname -DisplayName $fullname -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $activate
    }

}

Write-Host "Fin du script"
