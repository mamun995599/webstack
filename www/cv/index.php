<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CV Builder</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        body {
            background-color: #f8f9fa;
            padding-top: 2rem;
            padding-bottom: 2rem;
        }
        
        .cv-form-container {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
            padding: 2rem;
            margin-bottom: 2rem;
        }
        
        .profile-image-container {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .profile-image-preview {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            border: 5px solid #e9ecef;
            display: block;
            margin: 0 auto 1rem;
            background-color: #f8f9fa;
            overflow: hidden;
        }
        
        .profile-image-preview img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .section-title {
            border-bottom: 2px solid #0d6efd;
            padding-bottom: 0.5rem;
            margin-bottom: 1.5rem;
            color: #0d6efd;
        }
        
        .form-section {
            margin-bottom: 2rem;
        }
        
        .dynamic-field {
            margin-bottom: 1rem;
            padding: 1rem;
            border: 1px solid #e9ecef;
            border-radius: 5px;
            position: relative;
        }
        
        .remove-field {
            position: absolute;
            top: 10px;
            right: 10px;
            background-color: #dc3545;
            color: white;
            border: none;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }
        
        .qr-code-container {
            text-align: center;
            margin-top: 1rem;
            padding: 1rem;
            border: 1px dashed #ced4da;
            border-radius: 5px;
        }
        
        .btn-generate-pdf {
            background-color: #0d6efd;
            color: white;
            padding: 0.75rem 1.5rem;
            font-size: 1.1rem;
            border-radius: 5px;
            border: none;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        
        .btn-generate-pdf:hover {
            background-color: #0b5ed7;
        }
        
        .preview-section {
            background-color: #f8f9fa;
            padding: 2rem;
            border-radius: 5px;
            margin-top: 2rem;
            display: none;
        }
        
        .preview-title {
            text-align: center;
            margin-bottom: 1.5rem;
            color: #0d6efd;
        }
        
        .preview-content {
            background-color: white;
            padding: 2rem;
            border-radius: 5px;
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        }
        
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 25px;
            background-color: #28a745;
            color: white;
            border-radius: 5px;
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
            display: none;
            z-index: 1000;
        }
        
        .error-notification {
            background-color: #dc3545;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <div class="cv-form-container">
                    <h1 class="text-center mb-4">CV Builder</h1>
                    
                    <form id="cvForm" method="post" action="generate_pdf.php" enctype="multipart/form-data">
                        <!-- Profile Image Section -->
                        <div class="profile-image-container">
                            <div class="profile-image-preview" id="imagePreview">
                                <i class="fas fa-user fa-5x text-secondary"></i>
                            </div>
                            <div class="mb-3">
                                <input type="file" class="form-control" id="profileImage" name="profileImage" accept="image/*">
                            </div>
                        </div>
                        
                        <!-- Personal Information Section -->
                        <div class="form-section">
                            <h2 class="section-title">Personal Information</h2>
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="fullName" class="form-label">Full Name</label>
                                    <input type="text" class="form-control" id="fullName" name="fullName" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="personalJobTitle" class="form-label">Job Title</label>
                                    <input type="text" class="form-control" id="personalJobTitle" name="personalJobTitle" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="phone" class="form-label">Phone</label>
                                    <input type="tel" class="form-control" id="phone" name="phone" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="email" class="form-label">Email</label>
                                    <input type="email" class="form-control" id="email" name="email" required>
                                </div>
                                <div class="col-md-12 mb-3">
                                    <label for="address" class="form-label">Address</label>
                                    <input type="text" class="form-control" id="address" name="address" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="website" class="form-label">Website</label>
                                    <input type="url" class="form-control" id="website" name="website">
                                    <div class="qr-code-container" id="websiteQR"></div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="facebook" class="form-label">Facebook Profile</label>
                                    <input type="url" class="form-control" id="facebook" name="facebook">
                                    <div class="qr-code-container" id="facebookQR"></div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="linkedin" class="form-label">LinkedIn Profile</label>
                                    <input type="url" class="form-control" id="linkedin" name="linkedin">
                                    <div class="qr-code-container" id="linkedinQR"></div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="github" class="form-label">GitHub Profile</label>
                                    <input type="url" class="form-control" id="github" name="github">
                                    <div class="qr-code-container" id="githubQR"></div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Professional Summary Section -->
                        <div class="form-section">
                            <h2 class="section-title">Professional Summary</h2>
                            <div class="mb-3">
                                <textarea class="form-control" id="summary" name="summary" rows="5" required></textarea>
                            </div>
                        </div>
                        
                        <!-- Work Experience Section -->
                        <div class="form-section">
                            <h2 class="section-title">Work Experience</h2>
                            <div id="workExperienceContainer">
                                <div class="dynamic-field">
                                    <button type="button" class="remove-field"><i class="fas fa-times"></i></button>
                                    <div class="row">
                                        <div class="col-md-12 mb-3">
                                            <label class="form-label">Job Title</label>
                                            <input type="text" class="form-control" name="jobTitle[]" required>
                                        </div>
                                        <div class="col-md-12 mb-3">
                                            <label class="form-label">Company</label>
                                            <input type="text" class="form-control" name="company[]" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Start Date</label>
                                            <input type="month" class="form-control" name="startDate[]" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">End Date</label>
                                            <input type="month" class="form-control" name="endDate[]">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="currentJob[]">
                                                <label class="form-check-label">Currently Working</label>
                                            </div>
                                        </div>
                                        <div class="col-md-12 mb-3">
                                            <label class="form-label">Description</label>
                                            <textarea class="form-control" name="jobDescription[]" rows="3" required></textarea>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="btn btn-outline-primary" id="addWorkExperience">
                                <i class="fas fa-plus"></i> Add Work Experience
                            </button>
                        </div>
                        
                        <!-- Education Section -->
                        <div class="form-section">
                            <h2 class="section-title">Education</h2>
                            <div id="educationContainer">
                                <div class="dynamic-field">
                                    <button type="button" class="remove-field"><i class="fas fa-times"></i></button>
                                    <div class="row">
                                        <div class="col-md-12 mb-3">
                                            <label class="form-label">Degree</label>
                                            <input type="text" class="form-control" name="degree[]" required>
                                        </div>
                                        <div class="col-md-12 mb-3">
                                            <label class="form-label">Institution</label>
                                            <input type="text" class="form-control" name="institution[]" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Start Date</label>
                                            <input type="month" class="form-control" name="eduStartDate[]" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">End Date</label>
                                            <input type="month" class="form-control" name="eduEndDate[]">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="currentEducation[]">
                                                <label class="form-check-label">Currently Studying</label>
                                            </div>
                                        </div>
                                        <div class="col-md-12 mb-3">
                                            <label class="form-label">Description</label>
                                            <textarea class="form-control" name="eduDescription[]" rows="3"></textarea>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="btn btn-outline-primary" id="addEducation">
                                <i class="fas fa-plus"></i> Add Education
                            </button>
                        </div>
                        
                        <!-- Skills Section -->
                        <div class="form-section">
                            <h2 class="section-title">Skills</h2>
                            <div id="skillsContainer">
                                <div class="dynamic-field">
                                    <button type="button" class="remove-field"><i class="fas fa-times"></i></button>
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Skill Name</label>
                                            <input type="text" class="form-control" name="skillName[]" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Proficiency</label>
                                            <select class="form-select" name="skillLevel[]">
                                                <option value="Beginner">Beginner</option>
                                                <option value="Intermediate">Intermediate</option>
                                                <option value="Advanced">Advanced</option>
                                                <option value="Expert">Expert</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="btn btn-outline-primary" id="addSkill">
                                <i class="fas fa-plus"></i> Add Skill
                            </button>
                        </div>
                        
                        <!-- Languages Section -->
                        <div class="form-section">
                            <h2 class="section-title">Languages</h2>
                            <div id="languagesContainer">
                                <div class="dynamic-field">
                                    <button type="button" class="remove-field"><i class="fas fa-times"></i></button>
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Language</label>
                                            <input type="text" class="form-control" name="language[]" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Proficiency</label>
                                            <select class="form-select" name="languageLevel[]">
                                                <option value="Basic">Basic</option>
                                                <option value="Conversational">Conversational</option>
                                                <option value="Professional">Professional</option>
                                                <option value="Native">Native</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="btn btn-outline-primary" id="addLanguage">
                                <i class="fas fa-plus"></i> Add Language
                            </button>
                        </div>
                        
                        <!-- Certifications Section -->
                        <div class="form-section">
                            <h2 class="section-title">Certifications</h2>
                            <div id="certificationsContainer">
                                <div class="dynamic-field">
                                    <button type="button" class="remove-field"><i class="fas fa-times"></i></button>
                                    <div class="row">
                                        <div class="col-md-12 mb-3">
                                            <label class="form-label">Certification Name</label>
                                            <input type="text" class="form-control" name="certificationName[]" required>
                                        </div>
                                        <div class="col-md-12 mb-3">
                                            <label class="form-label">Issuing Organization</label>
                                            <input type="text" class="form-control" name="issuingOrganization[]" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Issue Date</label>
                                            <input type="month" class="form-control" name="certIssueDate[]" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Expiry Date</label>
                                            <input type="month" class="form-control" name="certExpiryDate[]">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="certNoExpiry[]">
                                                <label class="form-check-label">No Expiry</label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="btn btn-outline-primary" id="addCertification">
                                <i class="fas fa-plus"></i> Add Certification
                            </button>
                        </div>
                        
                        <!-- References Section -->
                        <div class="form-section">
                            <h2 class="section-title">References</h2>
                            <div id="referencesContainer">
                                <div class="dynamic-field">
                                    <button type="button" class="remove-field"><i class="fas fa-times"></i></button>
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Reference Name</label>
                                            <input type="text" class="form-control" name="referenceName[]" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Position</label>
                                            <input type="text" class="form-control" name="referencePosition[]" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Company</label>
                                            <input type="text" class="form-control" name="referenceCompany[]" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Email</label>
                                            <input type="email" class="form-control" name="referenceEmail[]">
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label">Phone</label>
                                            <input type="tel" class="form-control" name="referencePhone[]">
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="btn btn-outline-primary" id="addReference">
                                <i class="fas fa-plus"></i> Add Reference
                            </button>
                        </div>
                        
                        <div class="text-center mt-4">
                            <button type="button" class="btn btn-outline-secondary me-2" id="previewBtn">
                                <i class="fas fa-eye"></i> Preview CV
                            </button>
                            <button type="submit" class="btn-generate-pdf" name="generatePDF">
                                <i class="fas fa-file-pdf"></i> Generate PDF
                            </button>
                        </div>
                    </form>
                </div>
                
                <!-- Preview Section -->
                <div class="preview-section" id="previewSection">
                    <h2 class="preview-title">CV Preview</h2>
                    <div class="preview-content" id="previewContent">
                        <!-- Preview content will be generated here -->
                    </div>
                    <div class="text-center mt-3">
                        <button type="button" class="btn btn-secondary" id="closePreview">
                            <i class="fas fa-times"></i> Close Preview
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Notification -->
    <div class="notification" id="notification"></div>
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- qrcode.js -->
    <script src="https://cdn.jsdelivr.net/npm/qrcodejs@1.0.0/qrcode.min.js"></script>
    
    <script>
        $(document).ready(function() {
            // Profile image preview
            $('#profileImage').change(function() {
                const file = this.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        $('#imagePreview').html('<img src="' + e.target.result + '" alt="Profile Image">');
                    };
                    reader.readAsDataURL(file);
                }
            });
            
            // QR code generation
            function generateQRCode(inputId, containerId) {
                const url = $(`#${inputId}`).val();
                if (url) {
                    $(`#${containerId}`).empty();
                    new QRCode(document.getElementById(containerId), {
                        text: url,
                        width: 128,
                        height: 128,
                        colorDark: "#000000",
                        colorLight: "#ffffff",
                        correctLevel: QRCode.CorrectLevel.H
                    });
                } else {
                    $(`#${containerId}`).empty();
                }
            }
            
            // Generate QR codes for social media links
            $('#website, #facebook, #linkedin, #github').on('input', function() {
                generateQRCode('website', 'websiteQR');
                generateQRCode('facebook', 'facebookQR');
                generateQRCode('linkedin', 'linkedinQR');
                generateQRCode('github', 'githubQR');
            });
            
            // Add dynamic fields
            function addDynamicField(containerId, template) {
                const newField = $(template).clone();
                newField.find('input, textarea, select').val('');
                newField.find('input[type="checkbox"]').prop('checked', false);
                $(`#${containerId}`).append(newField);
            }
            
            // Work experience template
            const workExperienceTemplate = `
                <div class="dynamic-field">
                    <button type="button" class="remove-field"><i class="fas fa-times"></i></button>
                    <div class="row">
                        <div class="col-md-12 mb-3">
                            <label class="form-label">Job Title</label>
                            <input type="text" class="form-control" name="jobTitle[]" required>
                        </div>
                        <div class="col-md-12 mb-3">
                            <label class="form-label">Company</label>
                            <input type="text" class="form-control" name="company[]" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Start Date</label>
                            <input type="month" class="form-control" name="startDate[]" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">End Date</label>
                            <input type="month" class="form-control" name="endDate[]">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="currentJob[]">
                                <label class="form-check-label">Currently Working</label>
                            </div>
                        </div>
                        <div class="col-md-12 mb-3">
                            <label class="form-label">Description</label>
                            <textarea class="form-control" name="jobDescription[]" rows="3" required></textarea>
                        </div>
                    </div>
                </div>
            `;
            
            // Education template
            const educationTemplate = `
                <div class="dynamic-field">
                    <button type="button" class="remove-field"><i class="fas fa-times"></i></button>
                    <div class="row">
                        <div class="col-md-12 mb-3">
                            <label class="form-label">Degree</label>
                            <input type="text" class="form-control" name="degree[]" required>
                        </div>
                        <div class="col-md-12 mb-3">
                            <label class="form-label">Institution</label>
                            <input type="text" class="form-control" name="institution[]" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Start Date</label>
                            <input type="month" class="form-control" name="eduStartDate[]" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">End Date</label>
                            <input type="month" class="form-control" name="eduEndDate[]">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="currentEducation[]">
                                <label class="form-check-label">Currently Studying</label>
                            </div>
                        </div>
                        <div class="col-md-12 mb-3">
                            <label class="form-label">Description</label>
                            <textarea class="form-control" name="eduDescription[]" rows="3"></textarea>
                        </div>
                    </div>
                </div>
            `;
            
            // Skills template
            const skillsTemplate = `
                <div class="dynamic-field">
                    <button type="button" class="remove-field"><i class="fas fa-times"></i></button>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Skill Name</label>
                            <input type="text" class="form-control" name="skillName[]" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Proficiency</label>
                            <select class="form-select" name="skillLevel[]">
                                <option value="Beginner">Beginner</option>
                                <option value="Intermediate">Intermediate</option>
                                <option value="Advanced">Advanced</option>
                                <option value="Expert">Expert</option>
                            </select>
                        </div>
                    </div>
                </div>
            `;
            
            // Languages template
            const languagesTemplate = `
                <div class="dynamic-field">
                    <button type="button" class="remove-field"><i class="fas fa-times"></i></button>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Language</label>
                            <input type="text" class="form-control" name="language[]" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Proficiency</label>
                            <select class="form-select" name="languageLevel[]">
                                <option value="Basic">Basic</option>
                                <option value="Conversational">Conversational</option>
                                <option value="Professional">Professional</option>
                                <option value="Native">Native</option>
                            </select>
                        </div>
                    </div>
                </div>
            `;
            
            // Certifications template
            const certificationsTemplate = `
                <div class="dynamic-field">
                    <button type="button" class="remove-field"><i class="fas fa-times"></i></button>
                    <div class="row">
                        <div class="col-md-12 mb-3">
                            <label class="form-label">Certification Name</label>
                            <input type="text" class="form-control" name="certificationName[]" required>
                        </div>
                        <div class="col-md-12 mb-3">
                            <label class="form-label">Issuing Organization</label>
                            <input type="text" class="form-control" name="issuingOrganization[]" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Issue Date</label>
                            <input type="month" class="form-control" name="certIssueDate[]" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Expiry Date</label>
                            <input type="month" class="form-control" name="certExpiryDate[]">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="certNoExpiry[]">
                                <label class="form-check-label">No Expiry</label>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            
            // References template
            const referencesTemplate = `
                <div class="dynamic-field">
                    <button type="button" class="remove-field"><i class="fas fa-times"></i></button>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Reference Name</label>
                            <input type="text" class="form-control" name="referenceName[]" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Position</label>
                            <input type="text" class="form-control" name="referencePosition[]" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Company</label>
                            <input type="text" class="form-control" name="referenceCompany[]" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" class="form-control" name="referenceEmail[]">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Phone</label>
                            <input type="tel" class="form-control" name="referencePhone[]">
                        </div>
                    </div>
                </div>
            `;
            
            // Add field buttons
            $('#addWorkExperience').click(function() {
                addDynamicField('workExperienceContainer', workExperienceTemplate);
            });
            
            $('#addEducation').click(function() {
                addDynamicField('educationContainer', educationTemplate);
            });
            
            $('#addSkill').click(function() {
                addDynamicField('skillsContainer', skillsTemplate);
            });
            
            $('#addLanguage').click(function() {
                addDynamicField('languagesContainer', languagesTemplate);
            });
            
            $('#addCertification').click(function() {
                addDynamicField('certificationsContainer', certificationsTemplate);
            });
            
            $('#addReference').click(function() {
                addDynamicField('referencesContainer', referencesTemplate);
            });
            
            // Remove field buttons
            $(document).on('click', '.remove-field', function() {
                $(this).closest('.dynamic-field').remove();
            });
            
            // Current job checkbox
            $(document).on('change', 'input[name="currentJob[]"]', function() {
                const endDateField = $(this).closest('.row').find('input[name="endDate[]"]');
                if ($(this).is(':checked')) {
                    endDateField.prop('disabled', true).val('');
                } else {
                    endDateField.prop('disabled', false);
                }
            });
            
            // Current education checkbox
            $(document).on('change', 'input[name="currentEducation[]"]', function() {
                const endDateField = $(this).closest('.row').find('input[name="eduEndDate[]"]');
                if ($(this).is(':checked')) {
                    endDateField.prop('disabled', true).val('');
                } else {
                    endDateField.prop('disabled', false);
                }
            });
            
            // No expiry checkbox
            $(document).on('change', 'input[name="certNoExpiry[]"]', function() {
                const expiryDateField = $(this).closest('.row').find('input[name="certExpiryDate[]"]');
                if ($(this).is(':checked')) {
                    expiryDateField.prop('disabled', true).val('');
                } else {
                    expiryDateField.prop('disabled', false);
                }
            });
            
            // Preview CV
            $('#previewBtn').click(function() {
                generatePreview();
                $('#previewSection').show();
                $('html, body').animate({
                    scrollTop: $('#previewSection').offset().top
                }, 500);
            });
            
            // Close preview
            $('#closePreview').click(function() {
                $('#previewSection').hide();
            });
            
            function generatePreview() {
                const fullName = $('#fullName').val();
                const jobTitle = $('#personalJobTitle').val();
                const phone = $('#phone').val();
                const email = $('#email').val();
                const address = $('#address').val();
                const website = $('#website').val();
                const facebook = $('#facebook').val();
                const linkedin = $('#linkedin').val();
                const github = $('#github').val();
                const summary = $('#summary').val();
                
                let profileImageHtml = '<i class="fas fa-user fa-5x text-secondary"></i>';
                if ($('#profileImage')[0].files && $('#profileImage')[0].files[0]) {
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        profileImageHtml = `<img src="${e.target.result}" alt="Profile Image" style="width: 150px; height: 150px; border-radius: 50%; object-fit: cover;">`;
                        updatePreview();
                    };
                    reader.readAsDataURL($('#profileImage')[0].files[0]);
                }
                
                function updatePreview() {
                    let previewHtml = `
                        <div class="row">
                            <div class="col-md-3 text-center">
                                ${profileImageHtml}
                            </div>
                            <div class="col-md-9">
                                <h2>${fullName}</h2>
                                <h4>${jobTitle}</h4>
                                <p><i class="fas fa-phone"></i> ${phone}</p>
                                <p><i class="fas fa-envelope"></i> ${email}</p>
                                <p><i class="fas fa-map-marker-alt"></i> ${address}</p>
                                ${website ? `<p><i class="fas fa-globe"></i> ${website}</p>` : ''}
                                ${facebook ? `<p><i class="fab fa-facebook"></i> ${facebook}</p>` : ''}
                                ${linkedin ? `<p><i class="fab fa-linkedin"></i> ${linkedin}</p>` : ''}
                                ${github ? `<p><i class="fab fa-github"></i> ${github}</p>` : ''}
                            </div>
                        </div>
                        <hr>
                        <h3>Professional Summary</h3>
                        <p>${summary}</p>
                    `;
                    
                    // Add work experience
                    previewHtml += '<h3>Work Experience</h3>';
                    $('div[id="workExperienceContainer"] .dynamic-field').each(function() {
                        const jobTitle = $(this).find('input[name="jobTitle[]"]').val();
                        const company = $(this).find('input[name="company[]"]').val();
                        const startDate = $(this).find('input[name="startDate[]"]').val();
                        const endDate = $(this).find('input[name="endDate[]"]').val();
                        const currentJob = $(this).find('input[name="currentJob[]"]').is(':checked');
                        const description = $(this).find('textarea[name="jobDescription[]"]').val();
                        
                        if (jobTitle && company) {
                            previewHtml += `
                                <div class="mb-3">
                                    <h5>${jobTitle} at ${company}</h5>
                                    <p>${formatDate(startDate)} - ${currentJob ? 'Present' : formatDate(endDate)}</p>
                                    <p>${description}</p>
                                </div>
                            `;
                        }
                    });
                    
                    // Add education
                    previewHtml += '<h3>Education</h3>';
                    $('div[id="educationContainer"] .dynamic-field').each(function() {
                        const degree = $(this).find('input[name="degree[]"]').val();
                        const institution = $(this).find('input[name="institution[]"]').val();
                        const startDate = $(this).find('input[name="eduStartDate[]"]').val();
                        const endDate = $(this).find('input[name="eduEndDate[]"]').val();
                        const currentEducation = $(this).find('input[name="currentEducation[]"]').is(':checked');
                        const description = $(this).find('textarea[name="eduDescription[]"]').val();
                        
                        if (degree && institution) {
                            previewHtml += `
                                <div class="mb-3">
                                    <h5>${degree} from ${institution}</h5>
                                    <p>${formatDate(startDate)} - ${currentEducation ? 'Present' : formatDate(endDate)}</p>
                                    <p>${description}</p>
                                </div>
                            `;
                        }
                    });
                    
                    // Add skills
                    previewHtml += '<h3>Skills</h3>';
                    let skillsList = '<ul>';
                    $('div[id="skillsContainer"] .dynamic-field').each(function() {
                        const skillName = $(this).find('input[name="skillName[]"]').val();
                        const skillLevel = $(this).find('select[name="skillLevel[]"]').val();
                        
                        if (skillName) {
                            skillsList += `<li>${skillName} - ${skillLevel}</li>`;
                        }
                    });
                    skillsList += '</ul>';
                    previewHtml += skillsList;
                    
                    // Add languages
                    previewHtml += '<h3>Languages</h3>';
                    let languagesList = '<ul>';
                    $('div[id="languagesContainer"] .dynamic-field').each(function() {
                        const language = $(this).find('input[name="language[]"]').val();
                        const languageLevel = $(this).find('select[name="languageLevel[]"]').val();
                        
                        if (language) {
                            languagesList += `<li>${language} - ${languageLevel}</li>`;
                        }
                    });
                    languagesList += '</ul>';
                    previewHtml += languagesList;
                    
                    // Add certifications
                    previewHtml += '<h3>Certifications</h3>';
                    $('div[id="certificationsContainer"] .dynamic-field').each(function() {
                        const certName = $(this).find('input[name="certificationName[]"]').val();
                        const issuingOrg = $(this).find('input[name="issuingOrganization[]"]').val();
                        const issueDate = $(this).find('input[name="certIssueDate[]"]').val();
                        const expiryDate = $(this).find('input[name="certExpiryDate[]"]').val();
                        const noExpiry = $(this).find('input[name="certNoExpiry[]"]').is(':checked');
                        
                        if (certName && issuingOrg) {
                            previewHtml += `
                                <div class="mb-3">
                                    <h5>${certName} - ${issuingOrg}</h5>
                                    <p>Issued: ${formatDate(issueDate)} ${noExpiry ? '(No Expiry)' : '- Expires: ' + formatDate(expiryDate)}</p>
                                </div>
                            `;
                        }
                    });
                    
                    // Add references
                    previewHtml += '<h3>References</h3>';
                    $('div[id="referencesContainer"] .dynamic-field').each(function() {
                        const refName = $(this).find('input[name="referenceName[]"]').val();
                        const refPosition = $(this).find('input[name="referencePosition[]"]').val();
                        const refCompany = $(this).find('input[name="referenceCompany[]"]').val();
                        const refEmail = $(this).find('input[name="referenceEmail[]"]').val();
                        const refPhone = $(this).find('input[name="referencePhone[]"]').val();
                        
                        if (refName && refPosition && refCompany) {
                            previewHtml += `
                                <div class="mb-3">
                                    <h5>${refName}</h5>
                                    <p>${refPosition} at ${refCompany}</p>
                                    <p>${refEmail ? 'Email: ' + refEmail + '<br>' : ''}${refPhone ? 'Phone: ' + refPhone : ''}</p>
                                </div>
                            `;
                        }
                    });
                    
                    $('#previewContent').html(previewHtml);
                }
                
                function formatDate(dateString) {
                    if (!dateString) return '';
                    const date = new Date(dateString);
                    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
                    return `${months[date.getMonth()]} ${date.getFullYear()}`;
                }
                
                updatePreview();
            }
            
            // Show notification
            function showNotification(message, isError = false) {
                const notification = $('#notification');
                notification.text(message);
                
                if (isError) {
                    notification.addClass('error-notification');
                } else {
                    notification.removeClass('error-notification');
                }
                
                notification.fadeIn();
                
                setTimeout(function() {
                    notification.fadeOut();
                }, 3000);
            }
        });
    </script>
</body>
</html>