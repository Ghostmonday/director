# DirectorStudio - App Store Submission Guide

## 📋 Prerequisites Checklist

Before starting the submission process:

- [ ] ✅ App icons created (11 PNG files)
- [ ] ✅ Screenshots taken (iPhone 6.5", 5.5", iPad 12.9")
- [ ] ✅ Apple Developer Account ($99/year) - https://developer.apple.com
- [ ] ✅ Xcode installed and updated
- [ ] ✅ App tested on simulator
- [ ] ✅ All code committed and pushed to GitHub

---

## 🎨 Step 1: Add App Icons to Xcode

### 1.1 Create Asset Catalog Structure

```bash
cd DirectorStudioApp
mkdir -p Assets.xcassets/AppIcon.appiconset
```

### 1.2 Copy Icon Files

Place your 11 PNG files in `DirectorStudioApp/Assets.xcassets/AppIcon.appiconset/`:
- icon-20@2x.png (40x40)
- icon-20@3x.png (60x60)
- icon-29@2x.png (58x58)
- icon-29@3x.png (87x87)
- icon-40@2x.png (80x80)
- icon-40@3x.png (120x120)
- icon-60@2x.png (120x120)
- icon-60@3x.png (180x180)
- icon-76@2x.png (152x152)
- icon-83.5@2x.png (167x167)
- icon-1024.png (1024x1024)

### 1.3 Create Contents.json

Create `DirectorStudioApp/Assets.xcassets/AppIcon.appiconset/Contents.json`:

```json
{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "icon-20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "icon-20@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "icon-29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "icon-29@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "icon-40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "icon-40@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "icon-60@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "icon-60@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "icon-76@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "filename" : "icon-83.5@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "icon-1024.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
```

### 1.4 Update Xcode Project

1. Open `DirectorStudioApp.xcodeproj` in Xcode
2. Select the app target
3. General tab → App Icons and Launch Screen
4. Set App Icon to "AppIcon"
5. Build and verify icons appear

---

## 📦 Step 2: Build Archive

### 2.1 Prepare for Archive

1. **Open Xcode**
   ```bash
   open DirectorStudioApp.xcodeproj
   ```

2. **Select "Any iOS Device (arm64)"**
   - Top bar → Select device dropdown
   - Choose "Any iOS Device (arm64)"

3. **Set Build Configuration to Release**
   - Product → Scheme → Edit Scheme
   - Archive → Build Configuration → Release
   - Close

### 2.2 Create Archive

1. **Product → Archive**
   - This will take 2-5 minutes
   - Watch for any warnings or errors

2. **Wait for Organizer Window**
   - Archives window will open automatically
   - You should see your app with version 1.0

### 2.3 Verify Archive

- Build Date: Should be today
- Version: 1.0
- Build: 1
- Size: ~10-50 MB typical

---

## ☁️ Step 3: Upload to App Store Connect

### 3.1 Distribute App

1. **Click "Distribute App"** in Organizer
2. **Select "App Store Connect"** → Next
3. **Select "Upload"** → Next
4. **App Store Connect Distribution Options**:
   - ✅ Include bitcode for iOS content: YES
   - ✅ Upload your app's symbols: YES
   - ✅ Manage Version and Build Number: Automatic
5. **Click "Next"**

### 3.2 Re-sign (if needed)

- **Automatically manage signing**: Select this
- Click "Next"

### 3.3 Review and Upload

1. Review the summary
2. Click "Upload"
3. **Wait 5-15 minutes** for processing

### 3.4 Verify Upload

1. Go to https://appstoreconnect.apple.com
2. My Apps → DirectorStudio
3. TestFlight tab
4. Builds section → You should see "Processing" or "Ready to Submit"

---

## 🍎 Step 4: Prepare App Store Listing

### 4.1 Login to App Store Connect

https://appstoreconnect.apple.com

### 4.2 Create New App

1. Click "+" → New App
2. **Platforms**: iOS
3. **Name**: DirectorStudio
4. **Primary Language**: English (U.S.)
5. **Bundle ID**: com.yourdomain.directorstudio
6. **SKU**: directorstudio-001
7. **User Access**: Full Access

### 4.3 App Information

**Category**:
- Primary: Photo & Video
- Secondary: Productivity

**Age Rating**:
- 4+ (No mature content)

**Copyright**: © 2025 [Your Name/Company]

**Privacy Policy URL**: 
- Host PRIVACY_POLICY.md online (GitHub Pages, Vercel, etc.)
- Example: https://yourusername.github.io/director/privacy

**Support URL**:
- https://yourusername.github.io/director/support

---

### 4.4 Pricing and Availability

1. **Price**: Free
2. **Availability**: All territories
3. **Pre-orders**: No

---

### 4.5 Version Information (1.0)

#### App Information

**Promotional Text** (170 chars):
```
🎬 NEW: Transform your stories into cinematic video prompts! AI-powered segmentation, continuity checking, and professional production tools. Start creating today!
```

**Description** (4000 chars):
*Use the text from APP_STORE_METADATA.md*

**Keywords** (100 chars):
```
video,story,writing,ai,cinematic,movie,film,production,screenplay,editor,creator,narrative
```

**Support URL**: https://yourdomain.com/support

**Marketing URL**: https://yourdomain.com

#### What's New in This Version

*Use the "What's New" text from APP_STORE_METADATA.md*

---

### 4.6 Screenshots

Upload screenshots for each device size:

**iPhone 6.5" Display**:
- Upload 3-10 screenshots (1284 x 2778 px)
- Order: Most important first

**iPhone 5.5" Display**:
- Upload 3-10 screenshots (1242 x 2208 px)

**iPad Pro (3rd Gen) 12.9" Display**:
- Upload 3-10 screenshots (2048 x 2732 px)

**Tips**:
- Show key features
- Use device frames (optional but nice)
- Add text overlays explaining features (optional)
- Show the app in action, not just static screens

---

### 4.7 Build Selection

1. Under "Build" section
2. Click "+" next to build number
3. Select your uploaded build
4. Click "Done"

**Export Compliance**:
- Does your app use encryption? **No** (standard HTTPS doesn't count)

---

### 4.8 App Review Information

**Contact Information**:
- First Name: [Your First Name]
- Last Name: [Your Last Name]
- Phone: [Your Phone]
- Email: [Your Email]

**Demo Account** (if login required):
- Username: reviewer@directorstudio.app
- Password: ReviewPass2025!
- Notes: Full access demo account

**Notes for Reviewer**:
```
DirectorStudio is an iOS app for transforming written stories into structured video production prompts.

KEY FEATURES TO TEST:
1. Pipeline View - Enter a story and click "Run Pipeline"
2. Segmentation - Stories are broken into video segments
3. Story Analysis - View narrative insights
4. Projects - Organize multiple stories
5. Credits System - Test purchase flow (sandbox mode)

CREDITS: Test credits are provided for reviewers.

PRIVACY: We only access Photos when user explicitly exports/imports.

Thank you for reviewing DirectorStudio!
```

---

### 4.9 Age Rating Questionnaire

Answer all questions (all should be "No" for DirectorStudio):
- Alcohol, Tobacco, or Drug Use: No
- Contests: No
- Gambling: No
- Graphic Sexual Content or Nudity: No
- Horror or Fear Themes: No
- Mature or Suggestive Themes: No
- Profanity or Crude Humor: No
- Sexual Content or Nudity: No
- Realistic Violence: No
- Cartoon or Fantasy Violence: No
- Medical/Treatment Information: No
- Unrestricted Web Access: No
- Gambling and Contests: No

**Result**: 4+

---

## 🚀 Step 5: Submit for Review

### 5.1 Final Checks

- [ ] All required fields filled
- [ ] Screenshots uploaded for all device sizes
- [ ] Build selected
- [ ] Privacy Policy URL working
- [ ] Support URL working
- [ ] Age rating set
- [ ] Pricing set

### 5.2 Submit

1. Click "Add for Review" (top right)
2. Review "Version Release" options:
   - **Manually release this version**: Recommended for first release
3. Click "Submit for Review"

### 5.3 What Happens Next

**Review Timeline**:
- Typically 1-3 days
- Can be as fast as 24 hours
- Can take up to 7 days

**Status Updates**:
- "Waiting for Review": In queue
- "In Review": Apple is testing
- "Pending Developer Release": Approved! (if manual release selected)
- "Ready for Sale": Live on App Store!
- "Rejected": Need to fix issues and resubmit

---

## 📱 Step 6: TestFlight (Optional but Recommended)

Before submitting to App Review, test via TestFlight:

### 6.1 Add Internal Testers

1. App Store Connect → TestFlight
2. Internal Testing → Add testers
3. Testers receive email with TestFlight link

### 6.2 Add External Testers (Optional)

1. Create external testing group
2. Add up to 10,000 testers
3. Requires short App Review (faster than full review)

### 6.3 Test Build

- Install via TestFlight on real device
- Complete full testing checklist
- Fix any issues found
- Upload new build if needed

---

## 🐛 Common Issues & Solutions

### Issue: "Missing Compliance"
**Solution**: Answer export compliance questions (usually "No")

### Issue: "Invalid Binary"
**Solution**: Check code signing, rebuild archive

### Issue: "Missing Required Icon"
**Solution**: Ensure all 11 icon sizes are present

### Issue: "Missing Privacy Description"
**Solution**: Already done! Check Info.plist

### Issue: "Rejected - 2.1 App Completeness"
**Solution**: Ensure all features work, no placeholder content

### Issue: "Rejected - 4.0 Design"
**Solution**: Our UI is already Apple HIG compliant

---

## 📧 After Approval

### Set Up App Store Presence

1. **App Analytics**: Monitor downloads
2. **Customer Reviews**: Respond to feedback
3. **Version Updates**: Plan v1.1 features
4. **Marketing**: Share on social media

### Monitor Health

- Check crash reports in Xcode Organizer
- Monitor reviews in App Store Connect
- Track analytics and user engagement

---

## 🎉 Celebration Checklist

Once live:
- [ ] Download your own app from App Store
- [ ] Take screenshot of App Store listing
- [ ] Share with friends/family
- [ ] Post on social media
- [ ] Update your portfolio
- [ ] Start planning v1.1!

---

**Good luck with your submission! You've built something awesome! 🚀**

---

## Quick Reference

**App Store Connect**: https://appstoreconnect.apple.com
**Apple Developer**: https://developer.apple.com
**App Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
**Human Interface Guidelines**: https://developer.apple.com/design/human-interface-guidelines/

**Support**:
- Apple Developer Forums: https://developer.apple.com/forums/
- Stack Overflow: https://stackoverflow.com/questions/tagged/ios

