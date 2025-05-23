'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "1883dcba0d68e9363e1392c18c419603",
"version.json": "2d4838b4d438b9ff86b8c88f74804f00",
"index.html": "95d79e802c21e2e02916edbed8fe4ae7",
"/": "95d79e802c21e2e02916edbed8fe4ae7",
"main.dart.js": "59abaa84aab01c1f7442e38249395be1",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "4134bc0f76ab21aea0bf78d06c651028",
".git/config": "a89f459f3e1ffd776b02e0d5db325793",
".git/objects/66/5359ad58f199703f82995a328fac6a93761289": "26cf1368510e54503b9d8701c275007f",
".git/objects/57/7946daf6467a3f0a883583abfb8f1e57c86b54": "7a2beaf557655dfe4d49f90a155f8001",
".git/objects/03/2fe904174b32b7135766696dd37e9a95c1b4fd": "1cc6403c603e76bcc26b0586008b247e",
".git/objects/04/a26b6d6607f9dced5f9917b8cfce4c9c9a0575": "010d188f88b72f1ca30ade54c0e0178d",
".git/objects/35/96d08a5b8c249a9ff1eb36682aee2a23e61bac": "ecdf16b6e236ddf82afbc5360f5ce6bb",
".git/objects/51/85445188a89245e9c44c57461d936a9e6b7560": "0955cf08b6d9c215e4817827222be00e",
".git/objects/94/50c279b778429bc3f52344f2196c868e382665": "c6c912fad4204e58cb64612c8778cafa",
".git/objects/0e/d00182695149c7c1341949c81e748c6f1fdb17": "2bf2ec7442d7216eadcdedce4045a94b",
".git/objects/0e/0533e5babc5dc23723bedea798e28e11a8652d": "70e2f24a9d521e199f356836005a8732",
".git/objects/34/d82cf1def3b880bbef3355fdc0d2b8577755d5": "fd90f50ce3f44c91bb044b3d024c0825",
".git/objects/5f/bf1f5ee49ba64ffa8e24e19c0231e22add1631": "c507d69554096e8cf8f581a9e3e2421e",
".git/objects/05/a9c09613574de9b77071261d4429ad6457f4f3": "ac4627b63d6bbc4a63e59c613b45193e",
".git/objects/a3/d51824e7aadbe66a1744e7b0aab8fea0b99053": "7566dbc06789d880a3d9bfe835521aa8",
".git/objects/d9/3952e90f26e65356f31c60fc394efb26313167": "819a1bee2d98b54140582e489dcbb8ba",
".git/objects/d7/0bdf1b3fe928e2232b4c0033eab59331529666": "9fb1bccd2c6c3f62464280339967fe6a",
".git/objects/d0/60a6b0cc68c11e4c8f899a4d2e2774121bea22": "3e59011ad83059eba7872815c56f0823",
".git/objects/be/fce6af890a4edf6d3c858878b30c1c2e2cd803": "a6c70daafc28408c562234b3d09e0578",
".git/objects/df/7581ee6cd16b7a0c336c3172b220d39e23d06c": "c13768e255a9a1caaa3e10e31ecfe6a1",
".git/objects/df/d36a644cb310a53d72af85953d78c35e03ff65": "324bf8e6113c8de6e357deb9e28d91fd",
".git/objects/da/0463cb79e10c080a0e0bcfaa915c004a1b0246": "843de51dace0d3b04f2d7d332ae25ff4",
".git/objects/b4/700708912e9c8f2ae4a227780018abe5282a46": "53f311463beac4a982bd05a14e83470c",
".git/objects/a2/e232c040a5a5286e9f383308f5523ffc46be5c": "3b90df411f64365e7958c7cd671082b7",
".git/objects/a5/de584f4d25ef8aace1c5a0c190c3b31639895b": "5bea32f46d8e9e33e1e2bbb5c1523ffa",
".git/objects/bd/6be43d015a2a8a92db341ee519feb383a20cb4": "70bc1d07824e0d0a16b4211b42792fef",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "5a9f3522bf38ba5dd54f15a0f75cb0d7",
".git/objects/f3/709a83aedf1f03d6e04459831b12355a9b9ef1": "28153710279c4ac512d78eab4ff360c9",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "01d8a507be49f15714be4d17b6947e52",
".git/objects/ee/bbb748277e8ef2bb535c9fb1a188ef3234fc74": "c262d79ae185770518c28450f97b7fa7",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "aa30b45014e5ab878c26ecce9ea89743",
".git/objects/f2/c9ebab0d53e1f95e6b4943880321d0dc187ade": "88908e835f3a41103cb8bf0c6848b093",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "fb2ee964a7fc17b8cba79171cb799fa3",
".git/objects/f5/f4f40688f9e601a4989a0386f9bdce9d4eca9c": "56a45208358514078b69344881e7e315",
".git/objects/fe/7075d9dca2e049038018c71ff6064820a6428f": "1daecd81f6ab9d7f6baab2e34903cfea",
".git/objects/fe/ef09b635e13007ef4f68f76f8608bcea16c859": "262aa35037792cc3bec7860142f1acf1",
".git/objects/c6/06caa16378473a4bb9e8807b6f43e69acf30ad": "708ec387c1c405170e46ecb742b4d308",
".git/objects/ec/361605e9e785c47c62dd46a67f9c352731226b": "2950f778d5dda0c267b890b72f9e64de",
".git/objects/20/561d9e6fb22e8059acc7cf38243dbdcd42ebff": "2367374e7449e11c29320552da2e5737",
".git/objects/27/a297abdda86a3cbc2d04f0036af1e62ae008c7": "847cef55692aa6311c4c2f26d42b36b5",
".git/objects/11/bcbc79574e67457e9199d7dec0087614680301": "17dc2c811f7ef66d5d9f5b0b67e52fc4",
".git/objects/89/e5754ca82eabed47e114ed145d49951367db95": "cc808f47d71463897ad295bebbb0cb62",
".git/objects/45/1cd96138606303d9a161fcb40879507e5eff57": "5479bc691e68f64fd3e2c0cce8c00a6d",
".git/objects/1f/45b5bcaac804825befd9117111e700e8fcb782": "baf057c4b90805f732d24ac22cb10345",
".git/objects/73/5fe05d2d9072b1c725a7c5304bd56445371b1e": "60897b768b1848dede52743f3835bccd",
".git/objects/73/7f149c855c9ccd61a5e24ce64783eaf921c709": "ebf7d1a0954090a5cf6bdc36cbf3289e",
".git/objects/80/a183553ca8103e419472cbb97fe0b16a6cb2a0": "98972e974ee07921701cdbe86da22157",
".git/objects/74/4ec5f297a62341a0a106c6cc2f3e35a53e1a8b": "32af21aba1f4eaa9358620982aec7394",
".git/objects/74/a8b4a41f5dd363d7c23cda29667fa697b2d5d1": "7098fa22de996b4db3a702045ee97fb5",
".git/objects/28/f50d8ed51b2cfc71ca19ff575a654e92248b7b": "be6ae4dec7aa65a4e891c05c1eff4160",
".git/objects/28/6a48c5a453d73fb5ce555f9a0656a923e22e96": "f13379dccbe2138a188cfc578d9efd31",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "0e7fbd1f8845cbeb2cdbf944a84ebaee",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "b25b26893b8f92a4f583677ba27f0a7f",
".git/objects/4c/8930bd50c2f1495f14abebb4f786ffa9119b2b": "21ad9bd3d0e1f71b1380fad1077a734e",
".git/objects/26/d732e239e9ee1e35742a91dfa45ff76711c57a": "2b1422bcc05cb97c61798f841978b829",
".git/objects/26/c48c3edbe6aed99d380e12cd89a3d5d429ece1": "d2b02c1f9d72dbf0af921fa0378863be",
".git/objects/4d/1c2c4857861014cc3e6d75fa530b84ab51db4d": "14bef329d5c9ed2b3ed77387d0df8834",
".git/objects/86/34a97c911ebed728ca5d3ca1ecbd526e7e6533": "a19c71a985a50a082c95d30c9c7ade17",
".git/objects/88/5cfd9676d29a6d4c8f90372296926b3ba202d1": "1495cc2233da61ce225452727195b6ed",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e35fdc55764d9ed14315f6ff50093ab3",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "9524d053d0586a5f9416552b0602a196",
".git/objects/38/0075a3e0754bfc516f37d3de8647b5b94c0abe": "6d67b381f41c5563fbe506d850e5eb39",
".git/objects/36/08fc0f2779ac5bf4c1da62fd96c70465e4fb47": "b71c5bf0c75fbc5a87373519a464f205",
".git/objects/5c/fc9bb66f1af1e69dc95866a84824095e18f7e0": "44496e578695c74eac076eb1d71dd3b4",
".git/objects/5c/a5a8c5020db5823ca49e0ab645234786d918a7": "736e4bf82b64c6f8a4639a52ca2beec2",
".git/objects/31/603f111671cdc54f87e40501aaa599941e238c": "6771cd962e10410528199b954f747279",
".git/objects/31/39dc7cf301ea55d8f5e781d98d5c58a6ee1ccd": "a914fe9811936b2eabf167d088e78e67",
".git/objects/91/4a40ccb508c126fa995820d01ea15c69bb95f7": "bff9d14adbb36657694ef0fc6d5e6f7f",
".git/objects/3a/a39dace3e72256f6adb427100b5a95b3e34d5b": "f4318697031e70e2f4131f6b0a636b78",
".git/objects/98/5703737a1b8d02371cf4b742a1e6eccf7d134e": "f9fcd7fc588ee88ad4b1fcdfba270e73",
".git/objects/53/e225ee8f69609dab29dc01fdcc9547dc2fa2e4": "27318afb8b3fa87dff16489932ee69a4",
".git/objects/30/6942dc5bda024438722d4da845f397d2b10e14": "79d0ca2706eaa2c3b4da470e9db526a2",
".git/objects/5e/8448cfdd8ff56e1090bdec7886e124dc40e632": "1a0595353171d27e680e78c625539486",
".git/objects/5e/bf37944a56f2b5e479e3858392c6e9030da2da": "bfd14d13850066655518c7b7f8c8a70b",
".git/objects/5b/59a2aed1fdb4da33c01f2b2be51002748baf8f": "beb23672bf6adbf8d1dea7773e9d03c5",
".git/objects/6d/f2b253603094de7f39886aae03181c686e375b": "dae8dffe1b57334304dbe76d315d71ee",
".git/objects/6d/5f0fdc7ccbdf7d01fc607eb818f81a0165627e": "bcafa311bebf5634eaebc9a830559b6e",
".git/objects/01/1842b856d2844c35f671e492a3793c1dea487f": "4531f3dee36c45af5608d10f59b19249",
".git/objects/06/9cc9a87b446044c89b2ce1e0fb2be1bcfd0dca": "81d8716a695d3051fe46293687193b49",
".git/objects/6c/3276444aae417a27889a4736131a8d40aee5b5": "f8e346a78c09fec75c19f7fc06978050",
".git/objects/97/8a4d89de1d1e20408919ec3f54f9bba275d66f": "bf78de9a46b3f184061cc620c3ed1316",
".git/objects/63/6931bcaa0ab4c3ff63c22d54be8c048340177b": "bbebac4a2c902f61cd432f1208897318",
".git/objects/d3/aa6bcd29f1c3fd08758d0fcf7a661586af15e4": "feae1600a0507a7223a57aa8f0afb68a",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "9dbf5b01e391c548c8343be8d1d4b04e",
".git/objects/ba/5317db6066f0f7cfe94eec93dc654820ce848c": "5523d4e8db4b01938143b79a2a707ffd",
".git/objects/a0/9e4b0a0241fd2a05ac601aca78521615b0eeb9": "1851fa4676596bf7d4bdc473b96cb6fb",
".git/objects/b8/c9a6a84cd684fa434ba1d4ef329a5b759d3673": "20e29e555ca13dc5f88ac816b4b1082c",
".git/objects/b1/5ad935a6a00c2433c7fadad53602c1d0324365": "05f6258e74434f94977ac333a3891eeb",
".git/objects/b1/eee376b52e406979f1974ccfde035a964052bc": "43d666a6a016408e432f6d0b46853fba",
".git/objects/b1/afd5429fbe3cc7a88b89f454006eb7b018849a": "2c236ea17ad6b309081e0a5251137b84",
".git/objects/dd/494f373d6a7a51aae937eea8a1ff836ddb59ce": "0af84d042be16696ee72552015dd9672",
".git/objects/dc/f83695f71da8c6278eb914cdd42692c427924e": "70211b0a8348423a1f37454c4b604839",
".git/objects/d2/8b7d1687fd20f1eea5e8bf687ebf2e419c16cb": "6aedc333310d0b636aa4e43f784fda0c",
".git/objects/d2/46813172bfbc1f9883163b7872be01582dc6d6": "a826ac8bab9ab62d170be6b714e1a207",
".git/objects/af/31ef4d98c006d9ada76f407195ad20570cc8e1": "7f7a35d97b21f578a6e3dfc95f936101",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "b0c549c0aed479932cf26d094f76630e",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "936bdc921e2d2af84e1b88a53c8fc956",
".git/objects/b0/0372fb58e5487e0a1b28122053c10cc95387dd": "b7d3e8a36e31c3583ae4196c9826df62",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "9de9f2c6fa0aea6ee34b79162e9fc361",
".git/objects/ef/b875788e4094f6091d9caa43e35c77640aaf21": "06319d1126433915a2b82321cb327d7f",
".git/objects/c3/e81f822689e3b8c05262eec63e4769e0dea74c": "31782b0e3547365a9cae9df3a3668159",
".git/objects/e1/c9c4f9c2d240927cf85552a4edef31a8db4704": "9443cdc405527d911d3a4c219a374776",
".git/objects/e6/2450a1f2c465ee824ddda3c2c92188128c9cce": "7c11de59fc6b99c62b1c1af596fff0ee",
".git/objects/f7/a408e3f1e243cee318962a48501e065555334e": "2cdf82dc70e87f3192bcc9b98b91a4d9",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "c3694958e54483a81b3e32ab9f84ece2",
".git/objects/f8/d59a673df47ca957a3b3d73897aa7403229592": "0162e63bfd7951313a474d1646ac7d3f",
".git/objects/2d/4cf448c5eecd80dc958b3f4738eb89f697cef0": "9b0dca303d51639168aac50eb45ab9c2",
".git/objects/1e/54a86f80eec9b3da9d72d436cef5639fa8dc66": "f871db978d9bfb90ad61ec9097a315ba",
".git/objects/4f/02e9875cb698379e68a23ba5d25625e0e2e4bc": "bdc2f4ba1c16b2f697d776261713037a",
".git/objects/4f/346c3e43f95e778d7cef3cb6ceede9cd2bf1c8": "c3c094af00829b8acfa443209cc2f39d",
".git/objects/4f/521b9e7d3ff276fcec3cba7879f293e950c1f2": "97047f769745d8060cc8568727ab4bc1",
".git/objects/8c/7ba00d379183fc26cbf19df55cf292079eede3": "938dabb2ba8db7c8e09df1035ea3df15",
".git/objects/85/5aa8fdd80c44e86ed3e921d29aa627dede3dda": "7202aa2b4cff55246c1de1115e3a08ff",
".git/objects/85/bc4cb985605e975ae193cb391ec58b2020480d": "ce9bf67c54bd6573e649774e1a7fc844",
".git/objects/85/6a39233232244ba2497a38bdd13b2f0db12c82": "0a804c6a015be41c2f1307e32bf6b5bc",
".git/objects/1d/e554c606629d86c2d1c26692d6c456bd411a09": "8e2334f5fd6d18af82f08afa1bfcd0a5",
".git/objects/71/a85ff1a34cbea11a434ccc07113ed22849b52b": "14a0dfb029dbd2cb4c490cb5c7bedca6",
".git/objects/49/f7d4b3c7f11575c18da76baf6126af5dc50fd4": "e743af42b5e148e4a01b357244195d7f",
".git/objects/40/8a21940c257220bda31ba721e3ac1f23952854": "73b191f6c172e08535dc8ad3e65b435e",
".git/objects/40/1184f2840fcfb39ffde5f2f82fe5957c37d6fa": "3ac7af462afd2c09154fc9d4fe3ca9ec",
".git/objects/2e/b9094e7e54600cd40dd767ff9c2bbe52254eb3": "a2ff67e08d3aa2046247d0e6bfa7914c",
".git/objects/2b/14e844a0a613839c3f84dae056d9e914a4e0d9": "163899301d7e54815baaa60d4d24c4cc",
".git/objects/47/afc919aebdee067979a5bb1572b0f45670b4f7": "a56d105eb925435deeb9548d9c803da2",
".git/objects/7a/9021551bb955203e8c1c7dd7874381628484e2": "73fa95d21edc4e3380a25585c4ce4916",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "b004aa12ab73f047776ce551313acb6a",
".git/logs/refs/heads/main": "b004aa12ab73f047776ce551313acb6a",
".git/logs/refs/remotes/origin/main": "7ec7fbe94df72a58a26286c61ec27a2f",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/refs/heads/main": "2ad20b57a792d0ca56311990d39772d3",
".git/refs/remotes/origin/main": "2ad20b57a792d0ca56311990d39772d3",
".git/index": "63bbb8ba52bb0f614ced3c37e0293851",
".git/COMMIT_EDITMSG": "2796bf48df1007486e9868334b816545",
"assets/AssetManifest.json": "3e65f8c3d11565f637c804440224124c",
"assets/NOTICES": "866a3e35db6ae8be509e350568d1f029",
"assets/FontManifest.json": "0d648fbcad51ea4cd00cb983ddbccc17",
"assets/AssetManifest.bin.json": "c8f8b30193b2dae2de3a5df9b295fb8a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "43c16594466623e46f1f0a394b10e42c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "3ca5dc7621921b901d513cc1ce23788c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "00a0d5a58ed34a52b40eb372392a8b98",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/squiggly.png": "9894ce549037670d25d2c786036b810b",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/strikethrough.png": "26f6729eee851adb4b598e3470e73983",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/highlight.png": "2fbda47037f7c99871891ca5e57e030b",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/underline.png": "a98ff6a28215341f764f96d627a5d0f5",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/squiggly.png": "68960bf4e16479abb83841e54e1ae6f4",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/strikethrough.png": "72e2d23b4cdd8a9e5e9cadadf0f05a3f",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/highlight.png": "2aecc31aaa39ad43c978f209962a985c",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/underline.png": "59886133294dd6587b0beeac054b2ca3",
"assets/packages/syncfusion_flutter_pdfviewer/assets/fonts/RobotoMono-Regular.ttf": "5b04fdfec4c8c36e8ca574e40b7148bb",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "83c81994d9e971c60644907454463683",
"assets/fonts/MaterialIcons-Regular.otf": "74b9a04fc52eb35a1e14eea0f8a94de3",
"assets/assets/institutes.json": "20097b78be2f67bf80ec91ffce10db5e",
"assets/assets/classes.json": "de090bbe4790beb1aea27a1de3ac388c",
"assets/assets/country_city.json": "e31cf2fa8456b6b6999f36fbaab95c25",
"assets/assets/img.png": "ae85c470969f6269dc376ca0d3593779",
"assets/assets/its.png": "4664280d11bbe21aef2cf62e2f17f62f",
"assets/assets/demo.jpg": "6dcefc938fae8c001f66a778152c9acc",
"assets/assets/data.json": "a3002e483c13afcdc26a5fd2750e8704",
"assets/assets/anwar.jpg": "02e4e2d6e4efcecd7b4e6bb59babf66d",
"assets/assets/jamat_jamiat.json": "6b79b7f96707a7687d84e61e09c5e3e2",
"assets/assets/profile.pdf": "1af9fa3884f076c6f244114af13bd9b1",
"assets/assets/data/form_config.json": "c9e5c4de6c4490cfbaea12c527c83630",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
