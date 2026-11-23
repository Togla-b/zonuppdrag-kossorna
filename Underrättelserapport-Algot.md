# Underrättelserapport – Aktuella säkerhetshot: PHP och eMudhra

Den 20 oktober 2026 rapporterades två kritiska säkerhetshändelser. PHP-teamet meddelade att två sårbarheter, med CVSS-poängen 9,2 av 10, skulle åtgärdas genom en säkerhetsuppdatering den 21 oktober kl. 14.00 UTC. Sårbarheterna kan potentiellt möjliggöra fjärrkörning av kod på berörda servrar. CERT-EU rekommenderar därför att organisationer identifierar sina PHP-system och förbereder sig för att installera uppdateringen direkt när den blir tillgänglig. <Cite refs={["turn649932search0"]}/>

Samtidigt avslöjades att privata nycklar till åtta mellanliggande certifikatutfärdare hos eMudhra hade komprometterats. Bristande slumpmässighet vid nyckelgenereringen gjorde nycklarna osäkra. En angripare skulle potentiellt kunna skapa falska certifikat och utge sig för att vara legitima webbplatser eller tjänster. Mozilla och Google har bekräftat incidenten och vidtagit åtgärder för att blockera de berörda certifikaten. <Cite refs={["turn649932search2","turn649932search5","turn649932search4"]}/>

Båda händelserna visar hur tekniska brister kan hota organisationers system och förtroendet för digital kommunikation. Organisationer bör prioritera säkerhetsuppdateringar, kontrollera berörda system och säkerställa att certifikat och programvaror är uppdaterade. Cloudflare rekommenderar även att berörda applikationer byggs om och startas om vid behov efter uppdatering av beroenden. <Cite refs={["turn649932news23"]}/>

**Källor**

1. CERT-EU – [Critical Vulnerabilities in PHP](https://cert.europa.eu/publications/security-advisories/2026-018/)
2. PHP – [Officiella säkerhetsmeddelanden](https://www.php.net/archive/2026.php#2026-10-20-1)
3. eMudhra – [Intermediate CA Compromise](https://emudhra.we-have-a-problem.com/)
4. Mozilla – [Protecting Firefox users following the compromise](https://blog.mozilla.org/security/2026/10/20/protecting-firefox-users-following-the-compromise-of-emudhra-intermediate-certificates/)
5. Google – [Protecting Chrome and Android users](https://blog.google/security/protecting-chrome-and-android-users-from-compromised-emudhra-intermediate-ca-certificates/)
6. Cloudflare – [8 eMudhra certificates are compromised](https://blog.cloudflare.com/emudhra-certificate-compromise/)
