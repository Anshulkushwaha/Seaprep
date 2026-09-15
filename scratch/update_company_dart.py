with open(r'd:\stitch_merchant_navy_interview_pro\stitch_merchant_navy_interview_pro\assets\logos\zodiac_b64.txt', 'r') as f:
    data_uri = f.read().strip()

with open(r'd:\stitch_merchant_navy_interview_pro\stitch_merchant_navy_interview_pro\lib\models\company.dart', 'r') as f:
    content = f.read()

updated = content.replace('logoUrl: "assets/logos/zodiac.png"', f'logoUrl: "{data_uri}"')

with open(r'd:\stitch_merchant_navy_interview_pro\stitch_merchant_navy_interview_pro\lib\models\company.dart', 'w') as f:
    f.write(updated)

print('Company model updated!')
