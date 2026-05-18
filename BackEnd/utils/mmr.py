import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def mmr(doc_embedding, word_embeddings, words, top_n, diversity):
    word_doc_similarity = cosine_similarity(word_embeddings, doc_embedding)
    word_similarity = cosine_similarity(word_embeddings)

    keywords_idx = [np.argmax(word_doc_similarity)]
    candidates_idx = [i for i in range(len(words)) if i != keywords_idx[0]]

    for _ in range(top_n - 1):
        if not candidates_idx:
            break
        candidate_similarities = word_doc_similarity[candidates_idx, :]
        target_similarities = np.max(word_similarity[candidates_idx][:, keywords_idx], axis=1)

        mmr_score = (1-diversity) * candidate_similarities - diversity * target_similarities.reshape(-1, 1)
        mmr_idx = candidates_idx[np.argmax(mmr_score)]

        keywords_idx.append(mmr_idx)
        candidates_idx.remove(mmr_idx)

    return [words[idx] for idx in keywords_idx]

def extract_top_sentences_mmr(sentences, top_n=3, diversity=0.7):
    """
    Extract top N important sentences using MMR algorithm.
    diversity: 0 means focus on diversity, 1 means focus on relevance.
    """
    if len(sentences) <= top_n:
        return sentences
    
    vectorizer = TfidfVectorizer()
    
    doc = " ".join(sentences)
    all_texts = [doc] + sentences
    
    try:
        tfidf_matrix = vectorizer.fit_transform(all_texts)
    except ValueError:
        # e.g., if sentences are empty or don't have enough words
        return sentences[:top_n]
    
    doc_embedding = tfidf_matrix[0:1]
    word_embeddings = tfidf_matrix[1:]
    
    top_sentences = mmr(doc_embedding, word_embeddings, sentences, top_n, diversity)
    return top_sentences
