var formConfig = [
  {
    "title": "Intend",
    "key": "intendInfo",
  },
  // {
  //   "title": "Khidmat (HR)",
  //   "key": "khidmatInfo",
  //   "subSections": [
  //
  //   ]
  // },
  {
    "title": "Deeni",
    "key": "deeniInfo",
    "subSections": [
      {
        "title": "Khidmat Details",
        "key": "khidmatInfo",
        "fields": [
          {
            "type": "dropdown",
            "label": "Are you currently a part of any of the following khidmat avenues?",
            "key": "khidmatCurrent",
            "itemsKey": "khidmatOptions",
            "showDropdownIf": 5,
            "dropdownLabel": "Are you intending to be a part of any of the following khidmat avenues?",
            "dropdownKey": "khidmatIntent",
            "itemsKey2": "khidmatOptions"
          },
        ]
      },
      {
        "title": "Deeni Info",
        "key": "deeniInfo",
        "fields": [
          {
            "type": "radio",
            "label":
                "Have you studied Kalemat-ul-shahadah and 7 Daim ul Islam in school/madrasa?",
            "key": "studied_kalemat_daim",
            "options": ["Yes", "No"]
          },
          {
            "type": "radio",
            "label":
                "Have you memorized names of Dai-al-Zaman TUS / Mazoon Saheb / Mukasir Saheb?",
            "key": "memorized_names",
            "options": ["Yes", "No"]
          },
          {
            "type": "radio",
            "label": "Does he/she offer in Sila Fitra / Vajebaat? (Only HOF)",
            "key": "offers_sila_vajebaat",
            "options": ["Yes", "No"]
          },
          {
            "type": "radio",
            "label":
                "When have you latest attended misaq majlis to Dai-al-Zamaan TUS?",
            "key": "attended_misaq_majlis",
            "options": ["Yes", "No"]
          },
          {
            "type": "radio",
            "label":
                "Have you come to contact with any moharramaat – (prohibited activities) - Alcoholic substances/drugs/cigarette/Riba/ in your life?",
            "key": "contact_moharramaat",
            "options": ["Yes", "No"]
          },
          {
            "type": "dropdown",
            "label": "Shaadi?",
            "key": "shaadi_status",
            "itemsKey": "shaadiOptions",
            "showTextFieldIf": 0,
            "textFieldKey": "spouse_name",
            "textFieldLabel": "Spouse Name"
          },
          {
            "type": "dropdown",
            "label":
                "Does he/she attend all 9 days of Ashara Mubarakah punctually?",
            "key": "ashara_attendance",
            "itemsKey": "asharaAttendanceOptions"
          },
          {
            "type": "radio",
            "label": "Has he/she done ziyarat of Raudat Tahera?",
            "key": "ziyarat_raudat_tahera",
            "options": ["Yes", "No"]
          },
          {
            "type": "dropdown",
            "label": "Does he/she pray Namaz daily?",
            "key": "namaz_daily",
            "itemsKey": "namazDailyOptions"
          }
        ]
      }
    ]
  },
  // {
  //   "title": "Family",
  //   "key": "familyInfo",
  //   "subSections": [
  //   ]
  // },
  {
    "title": "Housing",
    "key": "housingInfo",
    "subSections": [
      {
        "title": "Father Info",
        "key": "fatherInfo",
        "fields": [
          {
            "type": "text",
            "label": "Name",
            "key": "father_name",
            "validator": "name"
          },
          {
            "type": "text",
            "label": "CNIC",
            "key": "father_cnic",
            "validator": "cnic"
          }
        ]
      },
      {
        "title": "Mother Info",
        "key": "motherInfo",
        "fields": [
          {
            "type": "text",
            "label": "Name",
            "key": "mother_name",
            "validator": "name"
          },
          {
            "type": "text",
            "label": "CNIC",
            "key": "mother_cnic",
            "validator": "cnic"
          }
        ]
      },
      {
        "title": "House Details",
        "key": "housingInfo",
        "fields": [
          {
            "type": "multiselect",
            "label": "Assets Owned",
            "key": "assets",
            "itemsKey": "assetsOptions"
          },
          {
            "type": "dropdown",
            "label": "House Title",
            "key": "house_title",
            "itemsKey": "houseTitleOptions"
          },
          {
            "type": "dropdown",
            "label": "Area of House",
            "key": "area",
            "itemsKey": "houseAreaOptions"
          },
          {
            "type": "dropdown",
            "label": "Neighborhood",
            "key": "neighborhood",
            "itemsKey": "neighborhoodOptions"
          },
          {
            "type": "dropdown",
            "label": "Drinking Water Source",
            "key": "drinking_water",
            "itemsKey": "drinkingWaterOptions"
          },
          {
            "type": "dropdown",
            "label": "Sanitation / Bathroom Type",
            "key": "sanitation_bathroom",
            "itemsKey": "sanitationBathroomOptions"
          },
          {
            "type": "radio",
            "label": "Are all walls/roof/flooring structure made of natural or light materials? (i.e mud,clay sand,cane, tree trunks, grass, bamboo, plastic, raw wood, stones, cardboard, tent etc.)",
            "key": "wallFlooring",
            "options": ["Yes", "No"]
          },
          {
            "type": "radio",
            "label": "Is there any leakage in the house?",
            "key": "leakage",
            "options": ["Yes", "No"]
          },
          {
            "type": "radio",
            "label": "Has a personal Bank Account?",
            "key": "personalBank",
            "options": ["Yes", "No"]
          },
        ]
      }
    ]
  },
  {
    "title": "FMB",
    "key": "fmbInfo",
    "subSections": [
      {
        "title": "FMB Details",
        "key": "fmbInfo",
        "fields": [
          {
            "type": "dropdown",
            "label": "Are you taking FMB Thali? (HOF)",
            "key": "taking_fmb",
            "itemsKey": "fmbThaliOptions"
          },
          {
            "type": "dropdown",
            "label": "Does the quantity suffice for the whole family?",
            "key": "fmb_quantity_sufficient",
            "itemsKey": "fmbQuantityOptions"
          }
        ]
      },
      {
        "title": "BMI",
        "key": "bmiInfo",
        "fields": [
          {"type": "text", "label": "Height (in cm)", "key": "height"},
          {"type": "text", "label": "Weight (in kg)", "key": "weight"}
        ]
      }
    ]
  },
  {
    "title": "Medical",
    "key": "medicalInfo",
    "subSections": [
      {
        "title": "Medical Info",
        "key": "medicalInfo",
        "fields": [
          {
            "type": "radio",
            "label":
                "Is there anyone who is physically or mentally challenged in the house? (HOF)",
            "key": "physically_mentally_challenged",
            "options": ["Yes", "No"]
          },
          {
            "type": "radio",
            "label": "Has any child died in the past 5 years?",
            "key": "child_death_past_5yrs",
            "options": ["Yes", "No"],
            "showDropdownIf": "Yes",
            "dropdownLabel": "Cause of Death",
            "dropdownKey": "child_death_cause",
            "itemsKey": "causeOptions"
          },
          {
            "type": "radio",
            "label":
                "Are all children in the household taking/taken the required vaccinations? (HOF)",
            "key": "vaccination_status",
            "options": ["Yes", "No"]
          },
          {
            "type": "radio",
            "label": "Any Chronic (long term, incurable) illness? (e.g.)",
            "key": "chronic_illness",
            "options": ["Yes", "No"]
          }
        ]
      }
    ]
  },
  {
    "title": "Financials",
    "key": "financialInfo",
    "subSections": [
      {
        "title": "Sources of Income",
        "key": "financialInfo",
        "fields": [
          {
            "label": "Income Type",
            "key": "incomeType",
            "type": "dropdown",
            "itemsKey": "incomeTypeOptions"
          },
          {
            "label": "Family Member Name",
            "key": "familyMemberName",
            "type": "text",
            "validator": "name"
          },
          {
            "label": "Student Part Time",
            "key": "studentPartTimeIncome",
            "type": "text",
            "validator": "number"
          },
          {
            "type": "radio",
            "label":
                "Is any member of the household unemployed but capable of working?",
            "key": "family_member_working",
            "options": ["Yes", "No"],
            "showTextFieldIf": "Yes",
            "textFieldKey": "workingDetails",
            "textFieldLabel": "Give Details"
          },
          {
            "type": "radio",
            "label":
                "Does any family member have a disability or chronic illness affecting earning capacity?",
            "key": "family_member_disability",
            "options": ["Yes", "No"],
            "showTextFieldIf": "Yes",
            "textFieldKey": "disabilityDetails",
            "textFieldLabel": "Give Details"
          },
          {
            "title": "Expenses Breakdown",
            "type": "totaling",
            "key": "expenseBreakdown",
            "fields": [
              {
                "label": "Wajebaat / Khumus",
                "key": "wajebaatExpenses",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "FMB Thaali / Niyaaz",
                "key": "niyazExpenses",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Jamaat Expenses / Sabeel",
                "key": "sabeelExpenses",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Ziyarat",
                "key": "zyaratExpenses",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Ashara Mubarakah",
                "key": "asharaExpenses",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Qardan Hasana",
                "key": "qardanHasana",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Others",
                "key": "otherExpenses",
                "type": "text",
                "validator": "number"
              }
            ]
          },
          {
            "title": "Education",
            "type": "repeatable",
            "key": "educationExpenses",
            "radioLabel": "No Education Expense",
            "fields": [
              {"label": "Name", "key": "eduName", "type": "text"},
              {"label": "Age", "key": "eduAge", "type": "text", "validator": "age"},
              {"label": "Institute Name", "key": "eduInsName", "type": "text"},
              {
                "label": "Class/Semester",
                "key": "eduSemClass",
                "type": "dropdown",
                "itemsKey": "semesterOptions"
              },
              {
                "label": "Fee",
                "key": "eduFee",
                "type": "text",
                "validator": "number"
              }
            ]
          },
          {
            "title": "Food Expense",
            "key": "foodExpense",
            "type": "totaling",
            "fields": [
              {
                "label": "Groceries & Household supplies",
                "key": "groceriesSupplies",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Retaurants / Dine Out",
                "key": "dineOutExpense",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Essentials",
                "key": "essentialExpense",
                "type": "text",
                "validator": "number"
              },
            ]
          },
          {
            "title": "Health",
            "key": "healthExpense",
            "type": "totaling",
            "fields": [
              {
                "label": "Doctor",
                "key": "docExpenses",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Dental",
                "key": "dentalExpenses",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Glasses & Eye Care",
                "key": "glassExpenses",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Medicines",
                "key": "medsExpenses",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Vacation",
                "key": "vacationExpenses",
                "type": "text",
                "validator": "number"
              },
            ]
          },
          {
            "title": "Standard of Living",
            "key": "sosExpense",
            "type": "totaling",
            "fields": [
              {
                "label": "Rent",
                "key": "rentExpense",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Maintenance",
                "key": "mainExpense",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Gas",
                "key": "gasExpense",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Electricity",
                "key": "electricityExpense",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Mobile",
                "key": "mobileExpense",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Water",
                "key": "waterExpense",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Cable",
                "key": "cableExpense",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Internet",
                "key": "internetExpense",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Clothing & Accessories",
                "key": "clothingExpense",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Appliances (Maintenance)",
                "key": "appliancesExpense",
                "type": "text",
                "validator": "number"
              },
              {
                "label": "Others",
                "key": "other2Expense",
                "type": "text",
                "validator": "number"
              },
            ]
          },
          {
            "title": "Dependents",
            "key": "dependentsExpense",
            "type": "repeatable",
            "radioLabel": "No Dependents",
            "fields": [
              {"label": "Dependent Name", "key": "dependentName", "type": "text"},
              {"label": "Dependent Age", "key": "dependentAge", "type": "age"},
            ]
          },
          {
            "title": "Travelling (Last 5 Years)",
            "key": "travellingExpense",
            "type": "repeatable",
            "radioLabel": "Not travelled",
            "fields": [
              {"label": "Place", "key": "travelPlace", "type": "text"},
              {"label": "Year", "key": "travelYear", "type": "year"},
              {"label": "Purpose", "key": "travelPurpose", "type": "text"},
            ]
          }
        ]
      },
      {
        "title": "Assets (Personal)",
        "key": "personalAssets",
        "type": "totaling",
        "fields": [
          {
            "label": "Property",
            "key": "propAssets",
            "type": "text",
            "validator": "number"
          },
          {
            "label": "Jewelry",
            "key": "JewAssets",
            "type": "text",
            "validator": "number"
          },
          {
            "label": "Transport",
            "key": "tranAssets",
            "type": "text",
            "validator": "number"
          },
          {
            "label": "Others",
            "key": "OthAssets",
            "type": "text",
            "validator": "number"
          },
        ]
      },
      {
        "title": "Business (Personal)",
        "key": "personalAssets",
        "type": "repeatable",
        "radioLabel": "No Business Assets",
        "fields": [
          {
            "label": "Amount",
            "key": "businessAssetAmount",
            "type": "text",
            "validator": "number"
          },
          {
            "label": "Description",
            "key": "businessAssetDesc",
            "type": "text",
            "validator": "text"
          },
        ]
      },
      {
        "title": "Liabilities (Qarzan Hasana Type/From)",
        "key": "qhLiability",
        "type": "repeatable",
        "radioLabel": "No Previous Qarzan Taken",
        "fields": [
          {
            "label": "ITS (Mother/Father",
            "key": "qhLiabilityITS",
            "type": "text",
            "validator": "its"
          },
          {
            "label": "Purpose",
            "key": "qhLiabilityPurpose",
            "type": "text",
            "validator": "text"
          },
          {
            "label": "Amount",
            "key": "qhLiabilityAmount",
            "type": "text",
            "validator": "text"
          },
          // {"label": "Reason if delay in payment", "key": "businessAssetDesc", "type": "dropdown", "itemsKey":"reason"},
        ]
      },
      {
        "title": "Enayat",
        "key": "enayatLiability",
        "type": "repeatable",
        "radioLabel": "No Previous Enayat",
        "fields": [
          {
            "label": "ITS",
            "key": "enayatLiabilityITS",
            "type": "text",
            "validator": "its"
          },
          {
            "label": "Purpose",
            "key": "enayatLiabilityPurpose",
            "type": "text",
            "validator": "text"
          },
          {
            "label": "Amount",
            "key": "enayatLiabilityAmount",
            "type": "text",
            "validator": "number"
          },
          {
            "label": "Date",
            "key": "enayatLiabilityDate",
            "type": "text",
            "validator": "date"
          },
        ]
      },
    ]
  },
  // {
  //   "title": "Financials (Expenses)",
  //   "key": "financialsExpenses",
  //   "subSections": [
  //
  //   ]
  // },
  // {
  //   "title": "Financials (Others)",
  //   "key": "financialsOthers",
  //   "subSections": [
  //
  //   ]
  // },
];
