using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace ThorEngine.Core
{
    public static class StringUtility
    {
        [ThreadStatic]
        private static StringBuilder s_CachedStringBuilder = new StringBuilder(256);

        private static StringBuilder CachedStringBuilder
        {
            get
            {
                if (s_CachedStringBuilder == null)
                {
                    s_CachedStringBuilder = new StringBuilder(256);
                }
                return s_CachedStringBuilder;
            }
            set
            {
                s_CachedStringBuilder = value;
            }
        }

        public static string Format(string format, object arg0)
        {
            if (string.IsNullOrEmpty(format))
            {
                return string.Empty;
            }
            CachedStringBuilder.Length = 0;
            CachedStringBuilder.AppendFormat(format, arg0);
            return CachedStringBuilder.ToString();
        }

        public static string Format(string format, object arg0, object arg1)
        {
            if (string.IsNullOrEmpty(format))
            {
                return string.Empty;
            }

            CachedStringBuilder.Length = 0;
            CachedStringBuilder.AppendFormat(format, arg0, arg1);
            return CachedStringBuilder.ToString();
        }

        public static string Format(string format, object arg0, object arg1, object arg2)
        {
            if (string.IsNullOrEmpty(format))
            {
                return string.Empty;
            }

            CachedStringBuilder.Length = 0;
            CachedStringBuilder.AppendFormat(format, arg0, arg1, arg2);
            return CachedStringBuilder.ToString();
        }

        public static string Format(string format, params object[] args)
        {
            if (string.IsNullOrEmpty(format))
            {
                return string.Empty;
            }

            if (args == null)
            {
                return format;
            }

            CachedStringBuilder.Length = 0;
            CachedStringBuilder.AppendFormat(format, args);
            return CachedStringBuilder.ToString();
        }

        public static string Concat(string s1, string s2)
        {
            CachedStringBuilder.Length = 0;
            CachedStringBuilder.Append(s1);
            CachedStringBuilder.Append(s2);
            return CachedStringBuilder.ToString();
        }

        public static string Concat(string s1, string s2, string s3)
        {
            CachedStringBuilder.Length = 0;
            CachedStringBuilder.Append(s1);
            CachedStringBuilder.Append(s2);
            CachedStringBuilder.Append(s3);
            return CachedStringBuilder.ToString();
        }

        public static string Concat(object[] args, string seq = "\t")
        {
            if(args == null || args.Length <= 0)
            {
                return string.Empty;
            }

            CachedStringBuilder.Length = 0;
            for(int i = 0; i < args.Length; ++i)
            {
                if(i > 0)
                {
                    CachedStringBuilder.Append(seq);
                }

                if(args[i] != null)
                {
                    CachedStringBuilder.Append(args[i].ToString());
                }
                else
                {
                    CachedStringBuilder.Append("null");
                }

            }

            return CachedStringBuilder.ToString();
        }

        public static string Concat<T>(T[] args, string seq = "\t")
        {
            object[] objectArgs = new object[args.Length];
            Array.Copy(args, objectArgs, args.Length);
            return Concat(objectArgs, seq);
        }

        #region DataStructTransfer
        /// <summary>
        /// string to vector3
        /// </summary>
        /// <param name="vectorStr">eg:(3,4,5)</param>
        /// <returns></returns>
        public static Vector3 StringToVector3(string vectorStr, char spliter, bool checkBrankets = true)
		{
			Vector3 result = Vector3.zero;
			if (string.IsNullOrEmpty(vectorStr))
			{
				return result;
			}
            if(checkBrankets)
            {
                if (vectorStr.IndexOf('(') < 0)
                {
                    Logger.LogError("Invalid input:" + vectorStr);
                    return result;
                }

                if (vectorStr.IndexOf(')') < 0)
                {
                    Logger.LogError("Invalid input:" + vectorStr);
                    return result;
                }
            }
            CachedStringBuilder.Length = 0;
			CachedStringBuilder.Append(vectorStr);
            if (checkBrankets)
            {
                CachedStringBuilder = CachedStringBuilder.Replace("(", "");
                CachedStringBuilder = CachedStringBuilder.Replace(")", "");
            }
			var strList = CachedStringBuilder.ToString().Split(spliter);
			if (strList.Length != 3)
			{
                Logger.LogError("Invalid input:" + vectorStr);
				return result;
			}

			if (float.TryParse(strList[0], out float x) && float.TryParse(strList[1], out float y) && float.TryParse(strList[2], out float z))
			{
				result = new Vector3(x, y, z);
			}
			else
			{
                Logger.LogError("Invalid input:" + vectorStr);
			}
			return result;
		}

        /// <summary>
        /// string to vector3
        /// </summary>
        /// <param name="vectorStr">eg:(3,4)</param>
        /// <returns></returns>
        public static Vector2 StringToVector2(string vectorStr, char spliter)
        {
            Vector2 result = Vector2.zero;
            if (string.IsNullOrEmpty(vectorStr))
            {
                return result;
            }
            if (vectorStr.IndexOf('(') < 0)
            {
                Logger.LogError("Invalid input:" + vectorStr);
                return result;
            }

            if (vectorStr.IndexOf(')') < 0)
            {
                Logger.LogError("Invalid input:" + vectorStr);
                return result;
            }
            CachedStringBuilder.Length = 0;
            CachedStringBuilder.Append(vectorStr);
            CachedStringBuilder = CachedStringBuilder.Replace("(", "");
            CachedStringBuilder = CachedStringBuilder.Replace(")", "");
            var strList = CachedStringBuilder.ToString().Split(spliter);
            if (strList.Length != 2)
            {
                Logger.LogError("Invalid input:" + vectorStr);
                return result;
            }

            if (float.TryParse(strList[0], out float x) && float.TryParse(strList[1], out float y))
            {
                result = new Vector2(x, y);
            }
            else
            {
                Logger.LogError("Invalid input:" + vectorStr);
            }
            return result;
        }


        public static List<int> String2IntList(string data, char splitter)
        {
            if (string.IsNullOrEmpty(data))
            {
                return null;
            }
            List<int> result = new List<int>();

            var strList = data.Split(splitter);
            foreach (var str in strList)
            {
                if (int.TryParse(str, out int value))
                {
                    result.Add(value);
                }
            }
            return result;
        }

        public static List<int> StringTable2IntList(string data, char splitter)
        {
            if (string.IsNullOrEmpty(data))
            {
                return null;
            }

            var tempStr = data.Replace("{","");
            tempStr = tempStr.Replace("}", "");
            return String2IntList(tempStr, splitter);
        }

        public static List<long> String2LongList(string data, char splitter)
        {
            if (string.IsNullOrEmpty(data))
            {
                return null;
            }
            List<long> result = new List<long>();

            var strList = data.Split(splitter);
            foreach (var str in strList)
            {
                if (long.TryParse(str, out long value))
                {
                    result.Add(value);
                }
            }
            return result;
        }

        #endregion

        #region DataParse
        public static long Parse(string s, long defaultValue)
        {
            if (string.IsNullOrEmpty(s) || !long.TryParse(s, out long result))
            {
                return defaultValue;
            }

            return result;
        }

        public static long Parse(object s, long defaultValue)
        {
            if (s == null)
            {
                return defaultValue;
            }
            var str = s.ToString();
            return Parse(str, defaultValue);
        }

        public static int Parse(string s, int defaultValue)
        {
            if (string.IsNullOrEmpty(s))
            {
                return defaultValue;
            }
            if (!int.TryParse(s, out int result))
            {
                Debug.LogErrorFormat("转换数据时出错，Source:{0}, Target: int", s);
                return defaultValue;
            }

            return result;
        }

        public static int Parse(object s, int defaultValue)
        {
            if (s == null)
            {
                return defaultValue;
            }
            var str = s.ToString();
            return Parse(str, defaultValue);
        }

        public static float Parse(string s, float defaultValue)
        {
            if (string.IsNullOrEmpty(s) || !float.TryParse(s, out float result))
            {
                return defaultValue;
            }

            return result;
        }

        public static float Parse(object s, float defaultValue)
        {
            if (s == null)
            {
                return defaultValue;
            }
            var str = s.ToString();
            return Parse(str, defaultValue);
        }

        public static bool Parse(string s, bool defaultValue)
        {
            if (string.IsNullOrEmpty(s))
            {
                return defaultValue;
            }

            return s == "true";
        }

        public static bool Parse(object s, bool defaultValue)
        {
            if (s == null)
            {
                return defaultValue;
            }
            var str = s.ToString();
            return Parse(str, defaultValue);
        }

        public static T GetValueByIndex<T>(IList<T> list, int index, T defaultValue)
        {
            if (list == null)
            {
                return defaultValue;
            }
            if (index < list.Count)
            {
                return list[index];
            }
            else
            {
                return defaultValue;
            }
        }
        #endregion


        /// <summary>
        /// 是不是全是数字
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static bool IsNumber(string s)
        {
            if (string.IsNullOrWhiteSpace(s))
            {
                return false;
            }
            for (int i = 0; i < s.Length; i++)
            {
                if (!char.IsNumber(s, i))
                {
                    return false;
                }
            }
            return true;
        }

        //只处理无table嵌套的情况
        public static string[] TableStringToStringArrayNoNesting(string table)
        {
            string[] ret;
            if (string.IsNullOrEmpty(table))
            {
                return null;
            }
            StringBuilder stringBuilder = new StringBuilder(table);
            stringBuilder = stringBuilder.Replace("{", "", 0, 1);
            stringBuilder = stringBuilder.Replace("}", "", stringBuilder.Length - 1, 1);

            var str = stringBuilder.ToString();
            ret = str.Split(',');
            return ret;
        }

        //去掉第一层括号
        ////input ->  0:"DEGREE_ATTACK",360,3.6,1.7,  {"PhysicalDamage"} ,{"TARGET_BUFF",{201008}}
        ////return->  0:"DEGREE_ATTACK",360,3.6,1.7,  1:"PhysicalDamage"  2:"TARGET_BUFF",{201008}
        public static string[] TableString2TableStringArray(string table)
        {
            //var strList = table.Split(",{");
            ////0:"DEGREE_ATTACK",360,3.6,1.7,  1:"PhysicalDamage"}  2:"TARGET_BUFF",201008}
            //for (int i = 0; i < strList.Length; i++)
            //{
            //    strList[i] = strList[i].Replace("}","");
            //}
            //return strList;

            //xxxx
            var totalLength = table.Length;
            int leftBranketNum = 0;
            List<int> resultIndexList = new List<int>();
            for (int i = 0; i < totalLength; i++)
            {
                var currentChar = table[i];
                if (currentChar == '{')
                {
                    if (leftBranketNum == 0)
                    {
                        if (resultIndexList.Count % 2 == 0)
                        {
                            resultIndexList.Add(i);
                        }
                    }
                    leftBranketNum++;
                }
                else if (currentChar == '}')
                {
                    if (leftBranketNum == 1)
                    {
                        if (resultIndexList.Count % 2 == 1)
                        {
                            resultIndexList.Add(i);
                        }
                    }
                    leftBranketNum--;
                }
            }
            resultIndexList.Insert(0, -1);
            resultIndexList.Add(table.Length);
            if (resultIndexList.Count % 2 == 1)
            {
                Debug.LogError("ActionTableString2StringArray ProcessFailed:" + table);
                return null;
            }
            List<string> result = new List<string>();
            for (int i = 0, j = 1; j < resultIndexList.Count; i++, j++)
            {
                if (resultIndexList[i] + 1 == resultIndexList[j])
                {
                    continue;
                }

                if (resultIndexList[i] + 2 == resultIndexList[j] && table[resultIndexList[i] + 1] == ',')
                {
                    continue;
                }
                result.Add(table.Substring(resultIndexList[i] + 1, resultIndexList[j] - resultIndexList[i] - 1));
            }

            return result.ToArray();
        }
    }
}
