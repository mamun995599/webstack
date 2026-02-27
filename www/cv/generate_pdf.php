<?php
// Include mPDF library
require_once 'vendor/autoload.php';

// Helper function to format date
function formatDate($dateString) {
    if (empty($dateString)) return '';
    $date = new DateTime($dateString);
    return $date->format('F Y');
}

// Check if form was submitted
if (isset($_POST['generatePDF'])) {
    try {
        // Get form data
        $fullName = $_POST['fullName'] ?? '';
        $jobTitle = $_POST['personalJobTitle'] ?? '';
        $phone = $_POST['phone'] ?? '';
        $email = $_POST['email'] ?? '';
        $address = $_POST['address'] ?? '';
        $website = $_POST['website'] ?? '';
        $facebook = $_POST['facebook'] ?? '';
        $linkedin = $_POST['linkedin'] ?? '';
        $github = $_POST['github'] ?? '';
        $summary = $_POST['summary'] ?? '';
        
        // Process profile image with simplified approach
        $profileImageHtml = '<div class="no-image">No Photo</div>';
        
        if (isset($_FILES['profileImage']) && $_FILES['profileImage']['error'] == UPLOAD_ERR_OK) {
            $uploadFile = $_FILES['profileImage'];
            $tmpName = $uploadFile['tmp_name'];
            
            // Get image info
            $imageInfo = @getimagesize($tmpName);
            
            if ($imageInfo !== false) {
                // Read image data directly
                $imageData = @file_get_contents($tmpName);
                
                if ($imageData !== false) {
                    // Get mime type
                    $mime = $imageInfo['mime'];
                    
                    // Create data URI
                    $dataUri = 'data:' . $mime . ';base64,' . base64_encode($imageData);
                    
                    // Create HTML
                    $profileImageHtml = '<img src="' . $dataUri . '" class="profile-image">';
                }
            }
        }
        
        // Generate QR codes
        $qrCodes = '';
        $urls = ['website' => $website, 'facebook' => $facebook, 'linkedin' => $linkedin, 'github' => $github];
        
        foreach ($urls as $key => $url) {
            if (!empty($url)) {
                $qrData = @file_get_contents('https://api.qrserver.com/v1/create-qr-code/?size=80x80&data=' . urlencode($url));
                if ($qrData !== false) {
                    $qrCodes .= '<div style="text-align: center; margin: 5px; display: inline-block;">
                        <img src="data:image/png;base64,' . base64_encode($qrData) . '" style="width: 50px; height: 50px; border: 1px solid #ddd; padding: 2px; background: white;" alt="' . ucfirst($key) . '">
                        <div style="font-size: 8px; margin-top: 2px;">' . ucfirst($key) . '</div>
                    </div>';
                }
            }
        }
        
        // Build HTML
        $html = '<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>CV - ' . htmlspecialchars($fullName) . '</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 10px;
            line-height: 1.3;
            font-size: 10px;
        }
        .header {
            display: flex;
            margin-bottom: 20px;
            border-bottom: 2px solid #0d6efd;
            padding-bottom: 15px;
        }
        .profile-section {
            text-align: center;
            margin-right: 20px;
            flex-shrink: 0;
        }
        .profile-image {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            border: 2px solid #e9ecef;
            display: inline-block;
            object-fit: cover;
        }
        .no-image {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background-color: #f8f9fa;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 2px solid #e9ecef;
            font-size: 8px;
            color: #6c757d;
            text-align: center;
        }
        .contact-info {
            flex: 1;
        }
        .contact-info h1 {
            margin: 0 0 3px 0;
            color: #333;
            font-size: 16px;
        }
        .contact-info h2 {
            margin: 0 0 8px 0;
            color: #666;
            font-size: 12px;
        }
        .contact-info p {
            margin: 2px 0;
            color: #555;
            font-size: 9px;
        }
        .qr-codes {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 8px;
            justify-content: center;
        }
        .section {
            margin-bottom: 15px;
            page-break-inside: avoid;
        }
        .section-title {
            color: #0d6efd;
            border-bottom: 1px solid #e9ecef;
            padding-bottom: 3px;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: bold;
        }
        .item {
            margin-bottom: 12px;
            page-break-inside: avoid;
        }
        .item-title {
            font-weight: bold;
            font-size: 11px;
            margin-bottom: 2px;
        }
        .item-subtitle {
            font-style: italic;
            color: #666;
            margin-bottom: 2px;
            font-size: 10px;
        }
        .item-date {
            color: #6c757d;
            font-size: 9px;
            margin-bottom: 5px;
        }
        .item p {
            margin: 5px 0 0 0;
            text-align: justify;
            font-size: 9px;
        }
        ul {
            margin: 5px 0;
            padding-left: 20px;
        }
        li {
            margin-bottom: 3px;
            font-size: 9px;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="profile-section">
            ' . $profileImageHtml . '
        </div>
        <div class="contact-info">
            <h1>' . htmlspecialchars($fullName) . '</h1>
            <h2>' . htmlspecialchars($jobTitle) . '</h2>
            <p>📞 ' . htmlspecialchars($phone) . '</p>
            <p>✉️ ' . htmlspecialchars($email) . '</p>
            <p>📍 ' . htmlspecialchars($address) . '</p>';
        
        if (!empty($qrCodes)) {
            $html .= '<div class="qr-codes">' . $qrCodes . '</div>';
        }
        
        $html .= '
        </div>
    </div>
    
    <div class="section">
        <h3 class="section-title">Professional Summary</h3>
        <p>' . nl2br(htmlspecialchars($summary)) . '</p>
    </div>';
        
        // Work Experience
        if (isset($_POST['jobTitle']) && is_array($_POST['jobTitle']) && !empty($_POST['jobTitle'][0])) {
            $html .= '<div class="section"><h3 class="section-title">Work Experience</h3>';
            
            $jobTitles = $_POST['jobTitle'] ?? [];
            $companies = $_POST['company'] ?? [];
            $startDates = $_POST['startDate'] ?? [];
            $endDates = $_POST['endDate'] ?? [];
            $currentJobs = $_POST['currentJob'] ?? [];
            $descriptions = $_POST['jobDescription'] ?? [];
            
            $count = count($jobTitles);
            for ($i = 0; $i < $count; $i++) {
                $jobTitle = $jobTitles[$i] ?? '';
                $company = $companies[$i] ?? '';
                $startDate = $startDates[$i] ?? '';
                $endDate = $endDates[$i] ?? '';
                $currentJob = isset($currentJobs[$i]) ? 'Present' : formatDate($endDate);
                $description = $descriptions[$i] ?? '';
                
                if (!empty($jobTitle) && !empty($company)) {
                    $html .= '
                    <div class="item">
                        <div class="item-title">' . htmlspecialchars($jobTitle) . '</div>
                        <div class="item-subtitle">' . htmlspecialchars($company) . '</div>
                        <div class="item-date">' . formatDate($startDate) . ' - ' . $currentJob . '</div>
                        <p>' . nl2br(htmlspecialchars($description)) . '</p>
                    </div>';
                }
            }
            
            $html .= '</div>';
        }
        
        // Education
        if (isset($_POST['degree']) && is_array($_POST['degree']) && !empty($_POST['degree'][0])) {
            $html .= '<div class="section"><h3 class="section-title">Education</h3>';
            
            $degrees = $_POST['degree'] ?? [];
            $institutions = $_POST['institution'] ?? [];
            $startDates = $_POST['eduStartDate'] ?? [];
            $endDates = $_POST['eduEndDate'] ?? [];
            $currentEducation = $_POST['currentEducation'] ?? [];
            $descriptions = $_POST['eduDescription'] ?? [];
            
            $count = count($degrees);
            for ($i = 0; $i < $count; $i++) {
                $degree = $degrees[$i] ?? '';
                $institution = $institutions[$i] ?? '';
                $startDate = $startDates[$i] ?? '';
                $endDate = $endDates[$i] ?? '';
                $isCurrentEducation = isset($currentEducation[$i]) ? 'Present' : formatDate($endDate);
                $description = $descriptions[$i] ?? '';
                
                if (!empty($degree) && !empty($institution)) {
                    $html .= '
                    <div class="item">
                        <div class="item-title">' . htmlspecialchars($degree) . '</div>
                        <div class="item-subtitle">' . htmlspecialchars($institution) . '</div>
                        <div class="item-date">' . formatDate($startDate) . ' - ' . $isCurrentEducation . '</div>
                        <p>' . nl2br(htmlspecialchars($description)) . '</p>
                    </div>';
                }
            }
            
            $html .= '</div>';
        }
        
        // Skills
        if (isset($_POST['skillName']) && is_array($_POST['skillName']) && !empty($_POST['skillName'][0])) {
            $html .= '<div class="section"><h3 class="section-title">Skills</h3><ul>';
            
            $skillNames = $_POST['skillName'] ?? [];
            $skillLevels = $_POST['skillLevel'] ?? [];
            
            $count = count($skillNames);
            for ($i = 0; $i < $count; $i++) {
                $skillName = $skillNames[$i] ?? '';
                $skillLevel = $skillLevels[$i] ?? '';
                
                if (!empty($skillName)) {
                    $html .= '<li>' . htmlspecialchars($skillName) . ' - ' . htmlspecialchars($skillLevel) . '</li>';
                }
            }
            
            $html .= '</ul></div>';
        }
        
        // Languages
        if (isset($_POST['language']) && is_array($_POST['language']) && !empty($_POST['language'][0])) {
            $html .= '<div class="section"><h3 class="section-title">Languages</h3><ul>';
            
            $languages = $_POST['language'] ?? [];
            $languageLevels = $_POST['languageLevel'] ?? [];
            
            $count = count($languages);
            for ($i = 0; $i < $count; $i++) {
                $language = $languages[$i] ?? '';
                $languageLevel = $languageLevels[$i] ?? '';
                
                if (!empty($language)) {
                    $html .= '<li>' . htmlspecialchars($language) . ' - ' . htmlspecialchars($languageLevel) . '</li>';
                }
            }
            
            $html .= '</ul></div>';
        }
        
        // Certifications
        if (isset($_POST['certificationName']) && is_array($_POST['certificationName']) && !empty($_POST['certificationName'][0])) {
            $html .= '<div class="section"><h3 class="section-title">Certifications</h3>';
            
            $certNames = $_POST['certificationName'] ?? [];
            $issuingOrgs = $_POST['issuingOrganization'] ?? [];
            $issueDates = $_POST['certIssueDate'] ?? [];
            $expiryDates = $_POST['certExpiryDate'] ?? [];
            $noExpiries = $_POST['certNoExpiry'] ?? [];
            
            $count = count($certNames);
            for ($i = 0; $i < $count; $i++) {
                $certName = $certNames[$i] ?? '';
                $issuingOrg = $issuingOrgs[$i] ?? '';
                $issueDate = $issueDates[$i] ?? '';
                $expiryDate = $expiryDates[$i] ?? '';
                $isNoExpiry = isset($noExpiries[$i]) ? 'No Expiry' : formatDate($expiryDate);
                
                if (!empty($certName) && !empty($issuingOrg)) {
                    $html .= '
                    <div class="item">
                        <div class="item-title">' . htmlspecialchars($certName) . '</div>
                        <div class="item-subtitle">' . htmlspecialchars($issuingOrg) . '</div>
                        <div class="item-date">Issued: ' . formatDate($issueDate) . ' - ' . $isNoExpiry . '</div>
                    </div>';
                }
            }
            
            $html .= '</div>';
        }
        
        // References
        if (isset($_POST['referenceName']) && is_array($_POST['referenceName']) && !empty($_POST['referenceName'][0])) {
            $html .= '<div class="section"><h3 class="section-title">References</h3>';
            
            $refNames = $_POST['referenceName'] ?? [];
            $refPositions = $_POST['referencePosition'] ?? [];
            $refCompanies = $_POST['referenceCompany'] ?? [];
            $refEmails = $_POST['referenceEmail'] ?? [];
            $refPhones = $_POST['referencePhone'] ?? [];
            
            $count = count($refNames);
            for ($i = 0; $i < $count; $i++) {
                $refName = $refNames[$i] ?? '';
                $refPosition = $refPositions[$i] ?? '';
                $refCompany = $refCompanies[$i] ?? '';
                $refEmail = $refEmails[$i] ?? '';
                $refPhone = $refPhones[$i] ?? '';
                
                if (!empty($refName) && !empty($refPosition) && !empty($refCompany)) {
                    $html .= '
                    <div class="item">
                        <div class="item-title">' . htmlspecialchars($refName) . '</div>
                        <div class="item-subtitle">' . htmlspecialchars($refPosition) . ' at ' . htmlspecialchars($refCompany) . '</div>';
                    
                    if (!empty($refEmail)) {
                        $html .= '<div>✉️ ' . htmlspecialchars($refEmail) . '</div>';
                    }
                    
                    if (!empty($refPhone)) {
                        $html .= '<div>📞 ' . htmlspecialchars($refPhone) . '</div>';
                    }
                    
                    $html .= '</div>';
                }
            }
            
            $html .= '</div>';
        }
        
        $html .= '
</body>
</html>';
        
        // Create mPDF with very basic configuration
        $mpdf = new \Mpdf\Mpdf([
            'mode' => 'utf-8',
            'format' => 'A4',
            'margin_left' => 10,
            'margin_right' => 10,
            'margin_top' => 10,
            'margin_bottom' => 10
        ]);
        
        // Set metadata
        $mpdf->SetTitle('CV - ' . $fullName);
        $mpdf->SetAuthor($fullName);
        $mpdf->SetCreator('CV Builder');
        
        // Write HTML to PDF
        $mpdf->WriteHTML($html);
        
        // Clean output buffer
        if (ob_get_level()) {
            ob_end_clean();
        }
        
        // Output PDF
        $filename = 'CV_' . preg_replace('/[^A-Za-z0-9_\-]/', '_', $fullName) . '.pdf';
        $mpdf->Output($filename, 'D');
        
        exit;
        
    } catch (Exception $e) {
        echo 'Error generating PDF: ' . $e->getMessage();
    }
}
?>