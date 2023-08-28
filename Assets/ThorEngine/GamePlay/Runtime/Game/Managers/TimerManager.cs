using LuaInterface;
using UnityEngine;
using System;
using System.Collections.Generic;
using UnityEngine.Profiling;

namespace ThorEngine.Core
{
    public enum TimerType
    {
        Normal,
        Frame 
    }
    public class TimerManager : Singleton<TimerManager>, IManager
    {

        private Dictionary<TimerType, MinHeap<TimerBase>> m_TimerHeapMap;
        private Dictionary<int, TimerBase> m_TimerDic;
        private int m_TimerIndex = 0;

        private TimerManager() { }

        [NoToLuaAttribute]
        public void Init()
        {
            m_TimerHeapMap = new Dictionary<TimerType, MinHeap<TimerBase>>();
            m_TimerHeapMap.Add(TimerType.Normal, new MinHeap<TimerBase>());
            m_TimerHeapMap.Add(TimerType.Frame, new MinHeap<TimerBase>());
            m_TimerDic = new Dictionary<int, TimerBase>();
        }

        //executeTimes:执行次数,0代表循环Timer
        public int AddTimer(Action callback, float interval = 0f, int executeTimes = 1)
        {
            if (executeTimes <= -1)
            {
                Debug.LogErrorFormat("[TimerManager](AddTimer execTimes invalid,{0})", executeTimes);
                return -1;
            }

            if (interval <= 0)
            {
                Debug.LogError("[TimerManager](AddTimer LoopTimer's interval need greater than 0)");
                return -1;
            }

            int timerIndex = m_TimerIndex;
            m_TimerIndex++;
            Timer timer = new Timer(callback, interval, executeTimes, timerIndex);
            timer.UpdateExecuteTime();
            m_TimerHeapMap[TimerType.Normal].Push(timer);
            m_TimerDic.Add(timerIndex, timer);
            return timer.timerIndex;
        }

        public int AddFrameTimer(Action callback, int intervalFrame = 1, int executeTimes = 1)
        {
            if (executeTimes <= -1)
            {
                Debug.LogErrorFormat("[TimerManager](AddFrameTimer execTimes invalid,{0})", executeTimes);
                return -1;
            }

            if (intervalFrame <= 0)
            {
                Debug.LogError("[TimerManager](AddFrameTimer LoopTimer's interval need greater than 0)");
                return -1;
            }

            int timerIndex = m_TimerIndex;
            m_TimerIndex++;
            FrameTimer timer = new FrameTimer(callback, intervalFrame, executeTimes, timerIndex);
            timer.UpdateExecuteTime();
            m_TimerHeapMap[TimerType.Frame].Push(timer);
            m_TimerDic.Add(timerIndex, timer);
            return timer.timerIndex;
        }

        public void RemoveTimer(int timerIndex)
        {
            if (m_TimerDic.TryGetValue(timerIndex, out var timer))
            {
                timer.isValid = false;
            }
        }

        public void RemoveAll()
        {
            foreach (var timerHeap in m_TimerHeapMap.Values)
            {
                foreach (var timer in timerHeap.GetElementList())
                {
                    timer.Destroy();
                }
                timerHeap.Clear();
            }
            m_TimerDic.Clear();
        }

        [NoToLuaAttribute]
        public void Update()
        {
            Profiler.BeginSample("TimerManager.Update");

            foreach (var timerHeap in m_TimerHeapMap.Values)
            {
                while (timerHeap.count > 0)
                {
                    TimerBase currentTimer = timerHeap.Peek();
                    if (currentTimer.IsExpired())
                    {
                        bool needRemove = false;
                        if (currentTimer.executeTimes > 0)
                        {
                            currentTimer.executeTimes -= 1;
                            if (currentTimer.executeTimes == 0)
                                needRemove = true;
                        }
                        if (currentTimer.isValid)
                        {
                            currentTimer.Execute();
                        }
                        timerHeap.Pop();
                        if (needRemove)
                        {
                            m_TimerDic.Remove(currentTimer.timerIndex);
                            currentTimer.Destroy();
                        }
                        else
                        {
                            currentTimer.UpdateExecuteTime();
                            timerHeap.Push(currentTimer);
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }

            Profiler.EndSample();
        }

        [NoToLuaAttribute]
        public void LateUpdate()
        {

        }

        [NoToLuaAttribute]
        public void FixedUpdate()
        {

        }

        [NoToLuaAttribute]
        public void Restart()
        {
            RemoveAll();
        }

        [NoToLuaAttribute]
        public void Destroy()
        {
            RemoveAll();
        }

        [NoToLuaAttribute]
        public void BeforeChangeScene(int prevSceneType, int nextSceneType)
        {

        }

        [NoToLuaAttribute]
        public void AfterChangeScene(int prevSceneType, int nextSceneType)
        {

        }

        [NoToLuaAttribute]
        public bool IsAutoUpdate()
        {
            return true;
        }
    }

    public class TimerBase: IComparable<TimerBase>
    {
        private Action m_CallBack;
        private int m_TimerIndex;
        public bool isValid { get; set; }

        public int timerIndex
        {
            get { return m_TimerIndex; }
        }
        public int executeTimes { get; set; }

        public bool isLoop
        {
            get { return executeTimes == 0; }
        }
      
        public TimerBase(Action callback,int executeTimes, int timerIndex)
        {
            m_CallBack = callback;
            this.executeTimes = executeTimes;
            m_TimerIndex = timerIndex;
            isValid = true;
        }

        public virtual void UpdateExecuteTime()
        {

        }

        public virtual bool IsExpired()
        {
            return true;
        }

        public void Execute()
        {
            if (m_CallBack == null)
            {
                return;
            }
            m_CallBack.Invoke();
        }

        public void Destroy()
        {
            if (m_CallBack != null)
            {
                m_CallBack = null;
            }
        }

        public virtual int CompareTo(TimerBase other)
        {
            return 0;
        }
    }


    public class FrameTimer : TimerBase
    {
        private int m_IntervalFrame;

        public float expiredFrame { get; set; }

        public FrameTimer(Action callback, int intervalFrame, int executeTimes, int timerIndex) : base(callback, executeTimes, timerIndex)
        {
            m_IntervalFrame = intervalFrame;
        }
        public override int CompareTo(TimerBase timer)
        {
            FrameTimer otherTimer = timer as FrameTimer;
            if (expiredFrame > otherTimer.expiredFrame)
            {
                return 1;
            }
            else if (expiredFrame < otherTimer.expiredFrame)
            {
                return 0;
            }
            else
            {
                return -1;
            }
        }

        public override bool IsExpired()
        {
            float currentFrame = Time.frameCount;
            if (currentFrame - expiredFrame >= 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public override void UpdateExecuteTime()
        {
            expiredFrame = Time.frameCount + m_IntervalFrame;
        }
    }


    public class Timer : TimerBase
    {
        private float m_Interval;
        public float expiredTime { get; set; }

        public Timer(Action callback, float interval, int executeTimes, int timerIndex):base(callback, executeTimes, timerIndex)
        {
            m_Interval = interval;
        }

        public override void UpdateExecuteTime()
        {
            expiredTime = Time.time + m_Interval;
        }

        public override bool IsExpired()
        {
            float currentTime = Time.time;
            if (currentTime - expiredTime >= 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public override int CompareTo(TimerBase timer)
        {
            Timer otherTimer = timer as Timer;
            if (expiredTime > otherTimer.expiredTime)
            {
                return 1;
            }
            else if (expiredTime - otherTimer.expiredTime < 0)
            {
                return 0;
            }
            else
            {
                return -1;
            }
        }
    }
}