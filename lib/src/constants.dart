import 'package:waves_spy/src/helpers/helpers.dart';

import 'models/asset.dart';

String getAddrName(String address) {
  String res = dAppsDict[address] ?? "";
  return res;
}

const publicNode = 'https://nodes.wavesnodes.com';
const localNode = 'http://127.0.0.1:6869';
const nodeUrl = publicNode;

const eggId = "C1iWsKGqLwjHUndiQ7iXpdmPum9PeCDFfyXBdJJosDRS";

Map<String, String> dAppsDict = {};

addPrvtAddr() {
  dAppsDict.addAll(privateAddr);
  showSnackMsg("Prvt addr added");
}

const publicAddr = {

  ///// Puzzle and Swop pools,
  "3P4v7QaMk6us7PdxSuoR5LmZmemv5ruD6oj": "SWOP.FI Router",
  "3P5UKXpQbom7GB2WGdPG5yGQPeQQuM3hFmw": "Keeper Aggregator",
  "3PGFHzVGT4NTigwCKP1NcwoXkodVZwvBuuU": "Puzzle Aggregator",
  "3PKUxbZaSYfsR7wu2HaAgiirHYwAMupDrYW": "Puzzle Eagles",
  "3PEZe3Z2FqaVbMTjWJUpnQGxhWh2JRptujM": "PUZZLE WW_POOL",
  "3P4bSEVNM3xdmFaefX5nc9qT4fDtbwo9Dx4": "PUZZLE GLOBAL_??",
  "3P9EydokbUM5XFrHgEUT9bNVgfF7fGmtxLk": "PUZZLE MUNA_BNB",
  "3PC87Z4vUzet6tTrTQmzJmW1UtouKjLhBJi": "PUZZLE DUCKLIZATION",
  "3PDrYPF6izza2sXWffzTPF7e2Fcir2CMpki": "PUZZLE DEFI",
  "3PPRHHF9JKvDLkAc3aHD3Kd5tRZp1CoqAJa": "PUZZLE FARMS_1",
  "3PKYPKJPHZENAAwH9e7TF5edDgukNxxBt3M": "PUZZLE FARMS_2",
  "3PNK5ypnPJioLmLUzfK6ezpaePHLxZd6QLj": "PUZZLE RACE_POOL",
  "3PMHkdVCzeLAYuCh92FPtusuxdLk5xMB51y": "PUZZLE EGG_POOL",
  "3PAviuHPCX8fD7M5fGpFTQZb4HchWCJb3ct": "PUZZLE WWW_POOL",
  "3PLiXyywNThdvf3vVEUxwc7TJTucjZvuegh": "PUZZLE BTC_ETH_POOL",
  "3PEStCRPQuW3phthTtQ5upGeb4WZ47kssyM": "PUZZLE SNSBT_POOL",
  "3PQnzp5YogBvJmwPnvSWoargPMcd1R4GLa8": "PUZZLE FORBES POOL",
  "3P3Z8Gn665CJr14bTLv4d5USDBUQCTeeCaT": "SWOP.FI RACE/EGG",
  "3PHTDdjz8Kb5JcAkhzfR57MCUYoe73pyxxK": "SWOP.FI WEST/EAST",
  "3PBHyEwmERR1CEkrTNbPj2bgyisTfPRqfee": "SWOP.FI PUZZLE/USDN",
  "3PHaNgomBkrvEL2QnuJarQVJa71wjw9qiqG": "SWOP.FI WAVES/USDN",
  "3P8FVZgAJUAq32UEZtTw84qS4zLqEREiEiP": "SWOP.FI WAVES/BTC",
  "3PACj2DLTw3uUhsUmT98zHU5M4hPufbHKav": "SWOP.FI BTC/USDN",
  "3PEcDN4sLSx6Pp4Y3m9vZzrgxtExfpFJr8w": "SWOP.FI EURN/USDN",
  "3P2V63Xd6BviDkeMzxhUw2SJyojByRz8a8m": "SWOP.FI NSBT/USDN",
  "3P8bovWtkLFVToB8LxP8AZLoWVwC8rDZLQQ": "SWOP.FI ENNO/USDN",
  "3PH8Np6jwuoikvkHL2qmdpFEHBR4UV5vwSq": "SWOP.FI SWOP/WAVES",
  "3PRFKemXs4rAJYGPccNtP63Kw2UzwEdH7sZ": "SWOP.FI PUZZLE/WAVES",
  "3PNVFWopwCD9CgGXkpYWEY94oQ5XCAEXBmQ": "SWOP.FI EGG/WAVES",
  "3P4Ftyud3U3xnuR8sTc1RvV4iQD62TcKndy": "SWOP.FI SIGN/USDN",
  "3P27S9V36kw2McjWRZ37AxTx8iwkd7HXw6W": "SWOP.FI SWOP/USDN",
  "3PEeJQRJT4v4XvSUBPmxhdWKz439nae7KtQ": "SWOP.FI EGG/USDN",
  "3PKy2mZqnvT2EtpwDim9Mgs6YvCRe4s85nX": "SWOP.FI FL/USDN",
  "3PJ48P3p2wvWUjgQaQiZ2cFbr8qmxMokBGd": "SWOP.FI VIRES/USDN",
  "3P6DLdJTP2EySq9MFdJu6beUevrQd2sVVBh": "SWOP.FI WEST/USDN",
  "3PK7Xe5BiedRyxHLuMQx5ey9riUQqvUths2": "SWOP.FI WAVES/EURN",
  "3PMDFxmG9uXAbuQgiNogZCBQASvCHt1Mdar": "SWOP.FI WCT/USDN",
  "3PKi4G3VX2k42ZSmNNrmvgdDH7JzRaUhY7R": "SWOP.FI WX/USDN",
  "3P9bPVN8aqfKCvTb5JiTHjter977XkeyJPk": "SWOP.FI MUNA/USDN",
  "3P32Rjpo9YHoHaorLSxvnV6CkKFXyfDCkJh": "SWOP.FI LTC/USDN",

  ///// Waves.Exchange,
  "3PPNhHYkkEy13gRWDCaruQyhNbX2GrjYSyV": "WX - LP Staking",
  "3PJL8Hn8LACaSBWLQ3UVhctA5cTQLBFwBAP": "WX Token staking",
  "3PKpsc1TNquw4HAF62pWK8ka1DBz9vyEBkt": "WX Token IDO",
  "3PCENpEKe8atwELZ7oCSmcdEfcRuKTrUx99": "WX Pools - WX/USDN",
  "3PCBWDTA6jrFswd7gQgaE3Xk7gLM5RKofvp": "WX Pools - BTC/USDN",
  "3P8NCvcipinDQVQZujpczBdvG7FL5EvTqLM": "WX Pools - BNB/USDN",
  "3P8KMyAJCPWNcyedqrmymxaeWonvmkhGauz": "WX Pools - USDT/USDN",
  "3PPZWgFNRKHLvM51pwS934C8VZ7d2F4Z58g": "WX Pools - WAVES/USDN",
  "3PEMqetsaJDbYMw1XGovmE37FB8VUhGnX9A": "WX Pools - ETH/USDN",
  "3PEjHv3JGjcWNpYEEkif2w8NXV4kbhnoGgu": "WEX Matcher",

  ///// Waves Ducks,
  "3PAETTtuW7aSiyKtn9GuML3RgtV1xdq1mQW": "WD - Farming",
  "3PEBtiSVLrqyYxGd76vXKu8FFWWsD1c5uYG": "WD - MArketPlace",
  "3PDVuU45H7Eh5dmtNbnRNRStGwULA7NY6Hb": "WD - Breeding",
  "3PKmLiGEfqLWMC1H9xhzqvAZKUXfFm8uoeg": "WD - Baby Duckling",
  "3PEktVux2RhchSN63DsDo4b4mz4QqzKSeDv": "WD - Incubator",
  "3PCC6fVHNa6289DTDmcUo3RuLaFmteZZsmQ": "WD - Rebirth",
  "3PR87TwfWio6HVUScSaHGMnFYkGyaVdFeqT": "WD - Game DAPP",
  "3P8ejTkfRpz9WqCwCuihesNXU5k3zmFFfVe": "WD - Referal",
  "3P5E9xamcWoymiqLx8ZdmR7o4fJSRMGp1WR": "WD - Lootbox",
  "3PPRqZYVaBUgTN4zGUFyYEcKLbqjVuoDZFP": "WD - Community dapp",
  "3PPG6zVNrMKnkqMthk5i2oHWQ5SHs9ertBM": "Team Rewards",
  "3PLkyPruTTLt2JfeHekaz7vHG2CWyBnwXDM": "Egg Treasury",
  "3P4QfR6fewW85epUg68fjgeFt3XBVpgLxmd": "MetaRace",
  "3P8JkeL2hVmp957Se45kaxXqXkggZ1SDNZd": "WD - Marketing",

  ///// WX Boosters,
  "3PE8KysWk7FYBkFx83RwSCfyQUaiAg8M9KQ": "WX Booster",
  "3P4ojtVYmnsAQYs8sgQZ9HjpZGBaByWNFkM": "WX Booster",
  "3PBDTqqbnqMbvM93Y7dzeSQs5o2qKksXkoS": "WX Booster",
  "3PLSRRuk1Uz98N2Vz9Tdq6DuVk6zcDUfrE5": "WX Booster",
  "3P4ohLRoRdcXG4n5wGXvT4MxaouzfT3bsDo": "WX Booster",
  "3PPF8URZjEByhzZK4DjPjAFHvSq2z1h4xBq": "WX Booster",
  "3PL9dN952HFUMXBoUktUQTQMYNXvsHMkBon": "WX Booster",

  ///// Waves Ducks Team (Farms),
  "3PKbd7pfmyaKWt6msaNAXyYUkuaumpea3bb": "Farm Granja Latina",
  "3P3y8NLGLYDx9obVaBF8je9uPTy2BDaK5n4": "Farm EggsAggerated",
  "3PEVpbeDDkjmKqiMm25MgMZfazR7U1Eivzi": "Farm Kolkhoz",
  "3PDs3ewniAQCp4LfXPMEqb2xRECgtZu2AR5": "Farm Forklog",
  "3PB8FTBTa1JspbXf8GiZTCdhYoq86QC6zxN": "Farm Mathematical",
  "3P6gnGQpT9iEABEy5AxMzMbm6ijGHSvXyeb": "Farm Marvin Favis",
  "3PJc5HTXgVWL7CYCec3huKJUtTPwJCNmMDF": "Farm Duxplorer",
  "3PEv4CE8moSLoAJw5y1bkiRMhtUF1nPRTfx": "Farm Duck Street",
  "3P3ohGCRmJzjTsP7RQ7jZV7QNw76wB1Nsnn": "Farm Eggpoint",
  "3P5me5qyR7z28WDkCiW172coLxpRZvqzeNv": "Farm Endo World",
  "3PJroXdKXF21FmcRjY6z7osZPP8VUY5R5Go": "Farm Insiders by GP",
  "3P6SQ4yDPRSzwk2nQD7ipK3HtxaEBX3M7Jk": "Farm CGU",
  "3P7iSFkjVr74EQqwExsg7DWRXX2SMn3BA3n": "Farm Mundocrypto",
  "3P3UMGin66fAe39AhJf5whS2Yabu6dZAmCF": "Farm FOMO",
  "3PCMKXu9r2ZNSxuLgnwoPXsWYhq6nMDADNo": "Farm Turtle",
  "3PEaA3SJb6wrfc2D4TPYTZ2xmMsufd7rCFJ": "Farm IDO",

  ///// Waves ducks Team staking dApps,
  "3P9d7k1FvWhahnSdyk5tb4kU33Fmee6NHKF": "Stake Latina",
  "3PPtUf3rhHYiHfsERX6qzXP3j5spqdrVrRm": "Stake EggsAggerated",
  "3PE2feY8CpBtWBRPxtLS7dt3YJkSt4Kme6U": "Stake Kolkhoz",
  "3PFdu9Kc2sUzLGjSv4axwr6Fe7dxqoYwkKR": "Stake Forklog",
  "3PBTLkeAM1HUEMExwJGeYwEGfuocg563zeg": "Stake Mathematical",
  "3P5zfgXtcjJxyMZves2sfSqGoabhzaMuPpZ": "Stake Marvin Favis",
  "3PJs4poBWAMFUM1Vn7T87mvNoZrts4esQbt": "Stake Duxplorer",
  "3P8968LuSXboHgKi94PHvc6c17duA6i8Hw8": "Stake Duck Street",
  "3P3L6F3yMiXkdMMXovdMrAP96FLYW7cg2Xq": "Stake Eggpoint",
  "3PJHPDM6kH8fGkPLkzwZ7SrNqc9JDXtMiPB": "Stake Endo World",
  "3PB6dcUYwDt6WHq6sma4ed7iUvEKvuP4b6B": "Stake Insiders by GP",
  "3PDMQbvFVLyxBnkwzbFEYokEda4EE7ZfdgS": "Stake CGU",
  "3PMZEydczD7NkUD45AY2kqvQRd2mTK8uqz1": "Stake Mundocrypto",
  "3P2bbfbAf2Ddc6cMgQfkt22fqmoE1AmALmN": "Stake FOMO",
  "3P48GkhK94aDgsavHhhsHGcYwcuLYQenWk4": "Stake Turtle",
  "3P79Pu5NmNv7REyWN78uZLiqVVb6WSpAg1d": "Stake IDO",

  ///// Neutrino dApps,
  "3PC9BfRwJWWiw9AREE2B3eWzCks3CYtg4yo": "Neutrino - USDN Collateral",
  "3P8w8NXZUtYdCA13tHbDY5sW4mC27ZFJgG3": "Neutrino - NSBT Staking",
  "3PQEjFmdcjd6wf1TrpkHSuDAk3zbfLSeikb": "Neutrino - Liquidity Pool",
  "3P5Bfd58PPfNvBM2Hy8QfbcDqMeNtzg7KfP": "Neutrino - Oracles",
  "3PNikM6yp4NqcSU8guxQtmR5onr2D4e8yTJ": "Neutrino - Staking",
  "3PG2vMhK5CPqsCDodvLGzQ84QkoHXCJ3oNP": "Neutrino - Auction",
  "3PFhcMmEZoQTQ6ohA844c7C9M8ZJ18P8dDj": "Neutrino - DeFo Staking",
  "3P7Uf5GF5feqnG39dTBEMqhGJzEq3T7MPUW": "Neutrino - EURN Collateral",
  "3P5fnEVxY8DFCNqfigRqFJRCjBAUbpP6Rr4": "Neutrino - RUBN Collateral",
  "3PMsU5VCcFrFnpKMh9EMMCYhjjiYTMNpMTa": "Neutrino - UAHN Collateral",
  "3P24H3bZrLHSRYFaUr7tFgUpL6Eic55Mv2b": "Neutrino - BRLN Collateral",
  "3P2xtvqBiofPU7aCrrT2iX3GXLNVodq8tUk": "Neutrino - TRYN Collateral",
  "3PPeM6UjZWjAkJDuuKoocZLwDcpyiSWNxWA": "Neutrino - CNYN Collateral",
  "3PMVZ6LtKhvcwnYB5p1e7JmhUKLUcNbdKFg": "Neutrino - GBPN Collateral",
  "3PPsoLQYRjvhQTfLYnaEm6BVeJLznBFrwZK": "Neutrino - JPYN Collateral",
  "3P4PCxsJqMzQBALo8zANHtBDZRRquobHQp7": "Neutrino - Liquidation",
  "3P3hCvE9ZfeMnZE6kXzR6YBzxhxM8J6PE7K": "Lambo Invest",

  //// Other dApps
  "3P6fAxtw12pjFhayEfpcUWxgu2BHVCeP78A": "PuzzleMarket",
  "3P3pDosq4GCwfJkvq4yqKvvoTwmoqc9qPmo": "DuckWrapper - PuzzleMarket",
  "3PDWpgk1ycioUwtzjoXKxUqYTzAgUG2mf8x": "Monster Presale",
  "3PMcMiMEs6w56NRGacksXtFG5zS7doE9fpL": "Forbes owner(Vova)",
  "3PF8pKC8CdmW9sEJUxQVSfezYRSJeThoNR3": "Pluto issuer",
  "3P9VVzzkP1Cfsk3LtTeuUaQqUt5D7sLthLe": "Pluto dApp"
};

const privateAddr = {
  ///// Private addresses,
  "3PDEEMRU3tBJffag7sRPnjwEQ8GZGikUWBi": "D**m_Pich",
  "3P5svutcwqdyivdjwfbapuehkxfnqsaquyf": "D**m_Pich2?",
  "3P9LTA2dBPNZfUhgnE7na9EyDeuqYdRSqTQ": "Di**ov_Main",
  "3PMyGoiQZgNQ8jWn4eKR6uZzSkRoWjdBdgW": "Di**ov_2",
  "3PPiRS1NfxRAdagsc2gS6F6GZeWadf8Ez1p": "Di**ov 3",
  "3P3188GUzTypcP2hKNe7Ys5X1S9yoNYjCU3": "Dasha Rewards",
  "3PD8eT53J3LcUM5HLnHMcYNAuLEKrQgC4bR": "Bu ** ip PUZzle",
  "3P3EgRSuPaavrVx8AavNVrTMLqtyPsNwPiy": "Dima Kript_on",
  "3PBwHmugtD1QXqGBzgQRnUdpGAUuE3VqTt6": "Waves ** Memes?",
  "3PPrR4GNrWdJibYCxezNXxDRkghJV5RVRbW": "Ck**ot",
  "3P6cgpyoErurDW3EdgUqUKuhFHza4xiFzpD": "St**n",
  "3PLUS2LnNbseGKcsQ68UVNSf1WxomDwpTAD": "B*ox",
  "3PEbL2T4FZSqHJJ67P41zW92E52K2t9GBAv": "@Steph091655 duckl_abu",
  "3PAtzncjJGWRpCtkR55wAzcfZ9fubMeA4JU": "R**a",
  "3PMKAL4cd77onkYuuU35115Wov1sLMEcFsv": "Ro**uz",
  "3P55AbxhmLtLztfPjLzGKd2TL3tfqCTHQdF": "Rom**eed",
  "3PPAAPAcT3rUV6LXfxj4e3MJ5wgxi37pDAM": "a***er_Puz_1",
};

// "INCUBATOR_DAPP_ADDRESS": "3PEktVux2RhchSN63DsDo4b4mz4QqzKSeDv",
// "AUCTION_DAPP_ADDRESS": "3PEBtiSVLrqyYxGd76vXKu8FFWWsD1c5uYG",
// "BREEDER_DAPP_ADDRESS": "3PDVuU45H7Eh5dmtNbnRNRStGwULA7NY6Hb",
// "FARMING_DAPP_ADDRESS": "3PAETTtuW7aSiyKtn9GuML3RgtV1xdq1mQW",
// "REFERRAL_DAPP_ADDRESS": "3P8ejTkfRpz9WqCwCuihesNXU5k3zmFFfVe",
// "REBIRTH_DAPP_ADDRESS": "3PCC6fVHNa6289DTDmcUo3RuLaFmteZZsmQ",
// "BABY_DUCKS_DAPP_ADDRESS": "3PKmLiGEfqLWMC1H9xhzqvAZKUXfFm8uoeg",
// "METARACE_DAPP_ADDRESS": "3P4QfR6fewW85epUg68fjgeFt3XBVpgLxmd",
// "LOOT_BOXES_DAPP_ADDRESS": "3P5E9xamcWoymiqLx8ZdmR7o4fJSRMGp1WR",
// "COMMUNITY_DUCK_DAPP_ADDRESS": "3PPRqZYVaBUgTN4zGUFyYEcKLbqjVuoDZFP",
// "GAME_DAPP_ADDRESS": "3PR87TwfWio6HVUScSaHGMnFYkGyaVdFeqT"

const typeDict = {
  3: "Issue",
  5: "Reissue",
  15: "Set asset script",
  17: "Update assetinfo",
  6: "Burn",
  4: "Transfer",
  7: "Exchange",
  10: "Alias",
  11: "Mass transfer",
  12: "Data",
  13: "Set script",
  16: "Invoke script",
  8: "Lease",
  9: "Lease cancel",
  14: "Set sponsorship"
};

const priorityThree = ["WAVES", "USDT", "USD-N", "USDC", "Puzzle", "Duck Egg"];
const priorityTwo = ["TEAM DUXPLORER", "TEAM EGGPOINT", "TEAM EGGSEGGS", "TEAM FOMO", "TEAM LATAM", "TEAM MATH", "TEAM MUNDOCRYPTO", "TEAM TURTLE", "TEM CGU", "TEAM ENDO", "TEAM FORK", "TEAM IDO", "TEAM KOLKHOZ", "TEAM MARVIN", "TEAM STREET"];
const priorityOne = ["VIRES", "Waves.Exchange", "WBTC", "WETH", "SWOP", "NSBT", "sNSBT"];