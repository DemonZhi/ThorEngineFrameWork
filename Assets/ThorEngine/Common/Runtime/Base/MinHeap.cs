using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ThorEngine.Core
{
    public class MinHeap<T> where T : IComparable<T>
    {
        private List<T> m_Elements;

        public int count
        {
            get { return m_Elements.Count; }
        }

        public MinHeap()
        {
            m_Elements = new List<T>();
        }

        public MinHeap(int capcaity)
        {
            m_Elements = new List<T>(capcaity);
        }

        public T Peek()
        {
            if (count <= 0)
            {
                return default;
            }
            return m_Elements[0];
        }

        public void Push(T item)
        {
            m_Elements.Add(item);
            int index = m_Elements.Count - 1;
            while (index > 0)
            {
                int parentIndex = (index - 1) / 2;
                if (m_Elements[parentIndex].CompareTo(m_Elements[index]) > 0)
                {
                    T temp = m_Elements[parentIndex];
                    m_Elements[parentIndex] = m_Elements[index];
                    m_Elements[index] = temp;
                }
                index = parentIndex;
            }
        }

        public void Pop()
        {
            if (m_Elements.Count <= 0)
            {
                return;
            }

            int parentIndex = 0;
            m_Elements[parentIndex] = m_Elements[m_Elements.Count - 1];
            m_Elements.RemoveAt(m_Elements.Count - 1);

            while (parentIndex < m_Elements.Count)
            {
                int leftChildIndex = parentIndex * 2 + 1;
                int rightChildIndex = leftChildIndex + 1;
                int minChildIndex;
                if (leftChildIndex < m_Elements.Count)
                {
                    minChildIndex = leftChildIndex;
                }
                else
                {
                    break;
                }

                if (rightChildIndex < m_Elements.Count &&
                    m_Elements[minChildIndex].CompareTo(m_Elements[rightChildIndex]) > 0)
                {
                    minChildIndex = rightChildIndex;
                }

                if (m_Elements[parentIndex].CompareTo(m_Elements[minChildIndex]) > 0)
                {
                    T temp = m_Elements[parentIndex];
                    m_Elements[parentIndex] = m_Elements[minChildIndex];
                    m_Elements[minChildIndex] = temp;
                    parentIndex = minChildIndex;
                }
                else
                {
                    break;
                }
             
            }
        }

        public List<T> GetElementList()
        {
            return m_Elements;
        }

        public void Clear()
        {
            m_Elements.Clear();
        }
    }
}