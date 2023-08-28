using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ThorEngine.Core
{
    /// <summary>
    /// 基于链表实现的队列
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class LinkedQueue<T> where T : class
    {
        #region [字段]
        private LinkedQueueNode<T> m_HeadNode; //头结点
        private LinkedQueueNode<T> m_TailNode; //尾结点
        private int m_Count;
        #endregion

        #region [属性]
        public LinkedQueueNode<T> HeadNode
        {
            get { return m_HeadNode; }
        }

        public LinkedQueueNode<T> TailNode
        {
            get { return m_TailNode; }
        }

        public bool IsEmpty
        {
            get { return m_HeadNode == null; } 
        }

        public int Count
        {
            get
            {
                return m_Count;
            }
        }
        #endregion

        #region [外部方法]
        public LinkedQueue()
        {
            m_HeadNode = null;
            m_TailNode = null;
            m_Count = 0;
        }

        /// <summary>
        /// 队尾插入
        /// </summary>
        /// <param name="queue"></param>
        public void Enqueue(LinkedQueue<T> queue)
        {
            if(queue == null || queue.HeadNode == null)
            {
                return;
            }

            if (m_HeadNode == null)
            {
                m_HeadNode = queue.HeadNode;
            }

            if (m_TailNode == null)
            {
                m_TailNode = queue.HeadNode;
            }
            else
            {
                m_TailNode.Next = queue.HeadNode;
            }

            while(m_TailNode.Next != null)
            {
                m_TailNode = m_TailNode.Next;
            }
            m_Count = m_Count + queue.Count;
        }

        /// <summary>
        /// 队尾插入
        /// </summary>
        /// <param name="data"></param>
        public void Enqueue(T data)
        {
            LinkedQueueNode<T> node = new LinkedQueueNode<T>(data);
            if(m_HeadNode == null)
            {
                m_HeadNode = node;
            }

            if(m_TailNode == null)
            {
                m_TailNode = node;
            }
            else
            {
                m_TailNode.Next = node;
                m_TailNode = node;
            }
            m_Count++;
        }

        /// <summary>
        /// 队头出队
        /// </summary>
        /// <returns></returns>
        public T Dequeue()
        {
            if(m_HeadNode == null)
            {
                return null;
            }

            LinkedQueueNode<T> node = m_HeadNode;
            m_HeadNode = m_HeadNode.Next;
            m_Count--;

            return node.Value;
        }

        /// <summary>
        /// 队列是否包含item元素
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        public bool Contain(T item)
        {
            LinkedQueueNode<T> node = m_HeadNode;

            while (node.Next != null)
            {
                if(item.Equals(node))
                {
                    return true;
                }
                node = node.Next;
            }
            return false;
        }

        /// <summary>
        /// 清空队列
        /// </summary>
        public void Clear()
        {
            m_HeadNode = null;
            m_TailNode = null;
            m_Count = 0;
        }
        #endregion

    }

    #region [LinkedQueueNode]
    public class LinkedQueueNode<T> where T : class
    {
        #region [字段]
        private T m_Value;
        private LinkedQueueNode<T> m_Next;
        #endregion

        #region [属性]
        public T Value
        {
            get { return m_Value; }
            set { m_Value = value; }
        }

        public LinkedQueueNode<T> Next
        {
            get { return m_Next; }
            set { m_Next = value; }
        }
        #endregion

        #region [构造函数]
        public LinkedQueueNode(T value, LinkedQueueNode<T> next = null)
        {
            m_Value = value;
            m_Next = next;
        }
        #endregion
    }
    #endregion
}

