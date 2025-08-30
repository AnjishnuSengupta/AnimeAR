#!/bin/bash

# Firebase and Firestore Setup Script for AnimeAR
# This script will help you set up Firebase and Firestore for your AnimeAR project

echo "🚀 Firebase and Firestore Setup for AnimeAR"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Firebase CLI is installed
check_firebase_cli() {
    echo -e "${BLUE}Checking Firebase CLI installation...${NC}"
    if ! command -v firebase &> /dev/null; then
        echo -e "${RED}❌ Firebase CLI is not installed.${NC}"
        echo -e "${YELLOW}Please install it using:${NC}"
        echo "npm install -g firebase-tools"
        echo "or"
        echo "curl -sL https://firebase.tools | bash"
        exit 1
    else
        echo -e "${GREEN}✅ Firebase CLI is installed${NC}"
        firebase --version
    fi
}

# Login to Firebase
firebase_login() {
    echo ""
    echo -e "${BLUE}Logging into Firebase...${NC}"
    echo -e "${YELLOW}This will open a browser window for authentication${NC}"
    firebase login
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully logged into Firebase${NC}"
    else
        echo -e "${RED}❌ Failed to login to Firebase${NC}"
        exit 1
    fi
}

# Initialize Firebase project
init_firebase() {
    echo ""
    echo -e "${BLUE}Initializing Firebase project...${NC}"
    echo -e "${YELLOW}Select the following when prompted:${NC}"
    echo "- Firestore: Configure security rules and indexes"
    echo "- Use existing project: nyanime-ar"
    echo "- Firestore rules file: firestore.rules"
    echo "- Firestore indexes file: firestore.indexes.json"
    echo ""
    
    firebase init firestore
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Firebase project initialized${NC}"
    else
        echo -e "${RED}❌ Failed to initialize Firebase project${NC}"
        exit 1
    fi
}

# Deploy Firestore rules
deploy_rules() {
    echo ""
    echo -e "${BLUE}Deploying Firestore security rules...${NC}"
    firebase deploy --only firestore:rules
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Firestore rules deployed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to deploy Firestore rules${NC}"
        exit 1
    fi
}

# Create Firestore database
create_database() {
    echo ""
    echo -e "${BLUE}Creating Firestore database...${NC}"
    echo -e "${YELLOW}Please follow these steps manually:${NC}"
    echo ""
    echo "1. Open: https://console.firebase.google.com/project/nyanime-ar/firestore"
    echo "2. Click 'Create database'"
    echo "3. Choose 'Start in production mode' (we have security rules)"
    echo "4. Select your preferred location (e.g., us-central1)"
    echo "5. Click 'Done'"
    echo ""
    echo -e "${YELLOW}Press Enter when you've completed these steps...${NC}"
    read -r
}

# Verify setup
verify_setup() {
    echo ""
    echo -e "${BLUE}Verifying setup...${NC}"
    
    # Check if firestore.rules exists
    if [ -f "firestore.rules" ]; then
        echo -e "${GREEN}✅ Firestore rules file exists${NC}"
    else
        echo -e "${RED}❌ Firestore rules file missing${NC}"
    fi
    
    # Check Firebase project
    firebase projects:list | grep -q "nyanime-ar"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Firebase project 'nyanime-ar' found${NC}"
    else
        echo -e "${RED}❌ Firebase project 'nyanime-ar' not found${NC}"
    fi
}

# Main execution
main() {
    echo -e "${YELLOW}This script will help you set up Firebase and Firestore for AnimeAR${NC}"
    echo -e "${YELLOW}Make sure you're in the AnimeAR project directory${NC}"
    echo ""
    
    # Check current directory
    if [ ! -f "pubspec.yaml" ]; then
        echo -e "${RED}❌ pubspec.yaml not found. Please run this script from the AnimeAR project root${NC}"
        exit 1
    fi
    
    check_firebase_cli
    firebase_login
    create_database
    init_firebase
    deploy_rules
    verify_setup
    
    echo ""
    echo -e "${GREEN}🎉 Setup complete!${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Run your Flutter app"
    echo "2. Sign in/Sign up in the app"
    echo "3. Check the Profile page - user data should now be visible"
    echo "4. Check Firebase console to see user documents being created"
    echo ""
    echo -e "${BLUE}Firebase Console: https://console.firebase.google.com/project/nyanime-ar/firestore${NC}"
}

# Run main function
main "$@"
